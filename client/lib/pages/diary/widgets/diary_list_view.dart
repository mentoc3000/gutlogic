import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../models/diary_entry/bowel_movement_entry.dart';
import '../../../models/diary_entry/diary_entry.dart';
import '../../../models/diary_entry/meal_entry.dart';
import '../../../models/diary_entry/symptom_entry.dart';
import 'bowel_movement_entry_list_tile.dart';
import 'date_tile.dart';
import 'meal_entry_list_tile.dart';
import 'no_entries_tile.dart';
import 'symptom_entry_list_tile.dart';

class DiaryListView extends StatelessWidget {
  final BuiltList<DiaryEntry> diaryEntries;

  const DiaryListView({Key? key, required this.diaryEntries}) : super(key: key);

  Widget _buildDiaryEntryTile(BuildContext context, DiaryEntry entry) {
    if (entry is MealEntry) {
      return MealEntryListTile(entry: entry);
    }
    if (entry is BowelMovementEntry) {
      return BowelMovementEntryListTile(entry: entry);
    }
    if (entry is SymptomEntry) {
      return SymptomEntryListTile(entry: entry);
    }
    throw ArgumentError.value(entry, 'Diary entry has no corresponding widget tile.');
  }

  List<Widget> _buildDiaryTiles(BuildContext context, List<DiaryEntry> entries) {
    // Sort and group by entry date.
    final groups = entries.sortedBy((e) => e.datetime).groupListsBy((e) => e.datetime.toLocal().toMidnight());

    // If there are no entries for today, add an empty list
    final today = DateTime.now().toLocal().toMidnight();

    groups.putIfAbsent(today, () => []);

    final dates = groups.keys.sorted().toList();
    final tiles = <Widget>[];

    for (var i = 0; i < dates.length; i++) {
      final date = dates[i];

      // Add date tile for entry
      tiles.add(DateTile(datetime: date.toLocal()));

      // Add entry tiles
      for (final entry in groups[date]!) {
        tiles.add(_buildDiaryEntryTile(context, entry));
      }

      // add space between gaps in entries
      if (i < dates.length - 1) {
        final deltaDays = dates[i + 1].difference(dates[i]);

        if (deltaDays > const Duration(days: 1)) {
          // Add date tile for no entries
          final emptyDate = dates[i].add(const Duration(days: 1));
          tiles.add(DateTile(datetime: emptyDate.toLocal()));

          // Add no entries tile
          final showEllipses = deltaDays > const Duration(days: 1);
          tiles.add(NoEntriesTile(showElipses: showEllipses));
        }
      }
    }

    // Add space at bottom so today can be at the top of the ListView
    // TODO: make last tile buffer height more robust
    tiles.add(Container(height: MediaQuery.of(context).size.height - 200));

    return tiles;
  }

  int _initialPosition(List<Widget> tiles) {
    final now = DateTime.now().toUtc();
    var lastDay = 0;
    // TODO revisit this loop
    for (var i = 0; i < tiles.length; i++) {
      DateTime datetime;
      final tile = tiles[i];
      if (tile is DateTile) {
        datetime = tile.datetime;
      } else {
        continue;
      }
      final diffDays = datetime.difference(now).inDays;
      if (diffDays >= 0) {
        return i;
      } else {
        lastDay = i;
      }
    }
    return lastDay;
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _buildDiaryTiles(context, diaryEntries.toList());

    return ScrollablePositionedList.builder(
      itemCount: tiles.length,
      itemBuilder: (BuildContext context, int index) => tiles[index],
      padding: const EdgeInsets.all(0.0),
      initialScrollIndex: _initialPosition(tiles),
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}

extension Date on DateTime {
  DateTime toMidnight() => DateTime(year, month, day);
}
