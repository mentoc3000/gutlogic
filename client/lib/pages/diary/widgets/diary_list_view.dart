import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../models/diary_entry/bowel_movement_entry.dart';
import '../../../models/diary_entry/diary_entry.dart';
import '../../../models/diary_entry/meal_entry.dart';
import '../../../models/diary_entry/symptom_entry.dart';
import '../../../util/date_time_ext.dart';
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
    // TODO: assign tile height dynamically based on actual widget size
    const heightDateTile = 200;
    tiles.add(Container(height: MediaQuery.of(context).size.height - heightDateTile));

    return tiles;
  }

  /// Index of the date tile closest to now
  int _latestDateTileIndex(List<Widget> tiles) {
    final now = DateTime.now().toUtc();
    var lastDay = 0;
    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];

      // Ignore non-DateTiles
      if (tile is! DateTile) continue;

      // Relative date of DateTile to now
      final diffDays = tile.datetime.difference(now).inDays;

      if (diffDays >= 0) {
        // If date is in the future, return that index immediately to use the first future date.
        return i;
      } else {
        // If the date is in the past, store it's index as the latest known DateTile index and continue to search
        // for a more recent one.
        lastDay = i;
      }
    }

    // Return the index of the DateTile of the latest day in the past
    return lastDay;
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _buildDiaryTiles(context, diaryEntries.toList());

    return ScrollablePositionedList.builder(
      itemCount: tiles.length,
      itemBuilder: (BuildContext context, int index) => tiles[index],
      padding: const EdgeInsets.all(0.0),
      initialScrollIndex: _latestDateTileIndex(tiles),
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}
