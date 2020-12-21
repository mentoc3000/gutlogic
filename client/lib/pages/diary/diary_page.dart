import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/diary/diary.dart';
import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../models/diary_entry/diary_entry.dart';
import '../../models/diary_entry/meal_entry.dart';
import '../../models/diary_entry/symptom_entry.dart';
import '../../util/keys.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/snack_bars/undo_delete_snack_bar.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/bowel_movement_entry_list_tile.dart';
import 'widgets/date_tile.dart';
import 'widgets/diary_floating_action_button.dart';
import 'widgets/meal_entry_list_tile.dart';
import 'widgets/no_entries_tile.dart';
import 'widgets/symptom_entry_list_tile.dart';

class DiaryPage extends StatelessWidget {
  static String tag = 'diary-page';

  /// Build a DiaryPage with its own DiaryBloc provider.
  static Widget provisioned() {
    return BlocProvider(
      create: (context) => DiaryBloc.fromContext(context)..add(const StreamAll()),
      child: DiaryPage(),
    );
  }

  Widget buildEntryTile(BuildContext context, DiaryEntry entry) {
    if (entry is MealEntry) {
      return MealEntryListTile(entry: entry);
    }
    if (entry is BowelMovementEntry) {
      return BowelMovementEntryListTile(entry: entry);
    }
    if (entry is SymptomEntry) {
      return SymptomEntryListTile(entry: entry);
    }
    return null;
  }

  List<Widget> entryToTiles(BuildContext context, List<DiaryEntry> entry) {
    if (entry.isEmpty) {
      return [];
    }

    entry.sort((a, b) => a.datetime.compareTo(b.datetime));

    final tiles = <Widget>[];
    for (var i = 0; i < entry.length; i++) {
      var isNewDay = true;

      if (i != 0) {
        final deltaDays = _dayDifference(entry[i].datetime, entry[i - 1].datetime);
        isNewDay = deltaDays > 0;

        if (deltaDays > 1) {
          // Add date tile for no entries
          final emptyDate = entry[i - 1].datetime.add(const Duration(days: 1));
          tiles.add(DateTile(datetime: emptyDate.toLocal()));

          // Add no entries tile
          final showElipses = deltaDays > 2;
          tiles.add(NoEntriesTile(showElipses: showElipses));
        }
      } else {
        isNewDay = true;
      }

      // Add date tile for entry
      if (isNewDay) {
        tiles.add(DateTile(datetime: entry[i].datetime.toLocal()));
      }

      // Add entry tile
      tiles.add(buildEntryTile(context, entry[i]));
    }

    return tiles;
  }

  int getInitialPosition(List<Widget> tiles) {
    final now = DateTime.now().toUtc();
    int lastDay;
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
    return GLScaffold(
      appBar: GLAppBar(title: 'Timeline'),
      body: BlocConsumer<DiaryBloc, DiaryState>(
        builder: (BuildContext context, DiaryState state) {
          if (state is DiaryLoading) {
            return LoadingPage();
          }
          if (state is DiaryLoaded) {
            if (state.diaryEntries.isEmpty) {
              return Column(children: <Widget>[]);
            } else {
              final tiles = entryToTiles(context, state.diaryEntries.toList());
              return ScrollablePositionedList.builder(
                itemCount: tiles.length,
                itemBuilder: (BuildContext context, int index) => tiles[index],
                padding: const EdgeInsets.all(0.0),
                initialScrollIndex: getInitialPosition(tiles),
                physics: const AlwaysScrollableScrollPhysics(),
              );
            }
          }
          if (state is DiaryError) {
            return ErrorPage(message: state.message);
          }
          return ErrorPage();
        },
        listener: (context, state) {
          if (state is DiaryEntryDeleted) {
            final snackBar = UndoDeleteSnackBar(
              name: 'entry',
              onUndelete: () => DiaryBloc.fromContext(context).add(Undelete(state.diaryEntry)),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          }
        },
      ),
      floatingActionButton: const DiaryFloatingActionButton(key: Keys.diaryFab),
    );
  }
}

int _dayDifference(DateTime datetime1, DateTime datetime2) {
  final localDt1 = datetime1.toLocal();
  final localMidnightDt1 = DateTime(localDt1.year, localDt1.month, localDt1.day);
  final localDt2 = datetime2.toLocal();
  final localMidnightDt2 = DateTime(localDt2.year, localDt2.month, localDt2.day);
  return localMidnightDt1.difference(localMidnightDt2).inDays;
}
