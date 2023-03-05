import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';

import '../models/diary_entry/diary_entry.dart';
import '../models/diary_entry/symptom_entry.dart';
import '../models/food_reference/food_reference.dart';
import '../models/irritant/irritant.dart';
import '../models/sensitivity/sensitivity_level.dart';
import '../models/severity.dart';
import '../models/symptom_type.dart';
import '../util/date_time_ext.dart';
import 'diary_repositories/diary_repository.dart';
import 'irritant_service.dart';
import 'pantry_service.dart';

class AnalysisService {
  final DiaryRepository diaryRepository;
  final PantryService pantryService;
  final IrritantService irritantService;

  const AnalysisService({required this.pantryService, required this.diaryRepository, required this.irritantService});

  Stream<BuiltMap<String, BuiltMap<SensitivityLevel, int>>> foodCountByIrritantAndLevel() async* {
    // Get all irritant names. Only needs to be done once because it will change infrequently.
    final irritantNames = await irritantService.names();

    yield* pantryService.streamAll().asyncMap((pantryEntries) async {
      // Create an empty map which will be filled with the data
      final map = {
        for (final n in irritantNames) n: {for (final s in SensitivityLevel.values) s: 0}
      };

      // Get the irritants of each food in the pantry and match it to the pantry entry
      final irritants = await Future.wait(pantryEntries.map((e) => irritantService.ofRef(e.foodReference)));
      final pantryIrritantPairs = Map.fromIterables(pantryEntries, irritants).entries;

      // For each food, add a count to the map
      for (final entry in pantryIrritantPairs) {
        if (entry.value == null) continue;
        final level = entry.key.sensitivity.level;
        final irritants = entry.value!
            .where((irritant) => map.containsKey(irritant.name))
            .where((irritant) => irritant.concentration > 0);
        for (final irritant in irritants) {
          final name = irritant.name;
          map[name]![level] = (map[name]![level] ?? 0) + 1;
        }
      }

      return map.map((key, value) => MapEntry(key, value.build())).build();
    });
  }

  Stream<BuiltMap<SensitivityLevel, BuiltList<FoodReference>>> foodsWithIrritantBySensitivityLevel(
      {required String irritantName}) {
    return pantryService.streamAll().asyncMap((pantryEntries) async {
      // Create an empty map which will be filled with the data
      final map = {for (final s in SensitivityLevel.list()) s: <FoodReference>[]};

      final foodReferences = pantryEntries.map((e) => e.foodReference);
      final irritants = await Future.wait(foodReferences.map(irritantService.ofRef));
      final pantryIrritantPairs = Map.fromIterables(pantryEntries, irritants).entries;

      for (final entry in pantryIrritantPairs) {
        final irritant = entry.value?.where((irritant) => irritant.concentration > 0).cast<Irritant?>().firstWhere(
              (irritant) => irritant?.name == irritantName,
              orElse: () => null,
            );
        if (irritant == null) continue;
        map[entry.key.sensitivity.level]?.add(entry.key.foodReference);
      }

      return map.map((key, value) => MapEntry(key, value.build())).build();
    });
  }

  /// Max severity by day for the [count] most recent days
  Stream<BuiltMap<DateTime, Severity?>> recentSeverity({required int count}) {
    return diaryRepository.streamAll().map((e) => _groupSeverity(e, count));
  }

  BuiltMap<DateTime, Severity?> _groupSeverity(BuiltList<DiaryEntry> event, int count) {
    final today = DateTime.now().toLocalMidnight();
    final days = List.generate(count, (index) => today.subtractDays(index));
    final start = days.last.toLocalMidnight();

    // Sort by most recent and group by date
    final diaryEntriesByDate = event
        .toList()
        .sortedBy((a) => a.datetime) // required for groupListsBy (TBC)
        .reversed // most recent dates first
        .takeWhile((value) => value.datetime.compareTo(start) >= 0) // remove dates outside of window
        .groupListsBy((e) => e.datetime.toLocalMidnight())
        .entries
        .sortedBy((element) => element.key);

    final maxSeveritiesMap = <DateTime, Severity?>{for (final d in days) d: null};

    // Get the maximum severity for each day
    for (final diaryEntryGroup in diaryEntriesByDate) {
      final date = diaryEntryGroup.key;
      for (final diaryEntry in diaryEntryGroup.value) {
        if (diaryEntry is SymptomEntry) {
          maxSeveritiesMap[date] ??= diaryEntry.symptom.severity;
          if (diaryEntry.symptom.severity > maxSeveritiesMap[date]!) {
            maxSeveritiesMap[date] = diaryEntry.symptom.severity;
          }
        }
      }
    }

    return BuiltMap(maxSeveritiesMap);
  }

  Stream<BuiltMap<SymptomType, int>> symptomTypeCount({DateTime? since}) {
    return diaryRepository.streamAll().map((e) => _countSymptomTypes(e, since: since));
  }

  BuiltMap<SymptomType, int> _countSymptomTypes(BuiltList<DiaryEntry> diary, {DateTime? since}) {
    final symptomEntries = diary.where((p0) => since == null || p0.datetime.isAfter(since)).whereType<SymptomEntry>();
    final typeCount = symptomEntries.groupFoldBy(
        (element) => element.symptom.symptomType, (int? previous, element) => previous == null ? 1 : previous + 1);
    return BuiltMap(typeCount);
  }

  /// Number of continuous days of diary entries by day for the most recent [count] number of days
  Stream<BuiltMap<DateTime, int>> diaryStreak({required int count}) {
    return diaryRepository.streamAll().map((e) => _countStreak(e, count));
  }

  BuiltMap<DateTime, int> _countStreak(BuiltList<DiaryEntry> event, int count) {
    final today = DateTime.now().toLocalMidnight();
    final days = List.generate(count, (index) => today.subtractDays(index));
    final countStart = days.last.toLocalMidnight();

    if (event.isEmpty) return BuiltMap({for (var d in days) d: 0});

    final diaryEntriesByDate = event
        .toList()
        .sortedBy((a) => a.datetime) // required for groupListsBy (TBC)
        .reversed // most recent dates first
        .groupListsBy((e) => e.datetime.toLocalMidnight());

    final diaryStart = diaryEntriesByDate.keys.reduce((value, element) => value.isBefore(element) ? value : element);

    final streak = {for (var d in days) d: 0};

    var streakCount = 0;
    var day = diaryStart.toLocalMidnight();

    while (!day.isAfter(today)) {
      // Increment count if there are diary entries on day
      if (diaryEntriesByDate[day]?.isNotEmpty ?? false) {
        streakCount += 1;
      } else {
        streakCount = 0;
      }

      // Set streak count
      if (!day.isBefore(countStart)) {
        streak[day] = streakCount;
      }

      day = day.addDays(1);
    }

    return BuiltMap(streak);
  }
}
