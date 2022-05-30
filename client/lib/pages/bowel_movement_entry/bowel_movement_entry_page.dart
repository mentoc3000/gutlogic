import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bowel_movement_entry/bowel_movement_entry.dart';
import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../widgets/cards/datetime_card.dart';
import '../../widgets/cards/notes_card.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/bm_type_card.dart';
import 'widgets/bm_volume_card.dart';

class BowelMovementEntryPage extends StatefulWidget {
  static String tag = 'bm-entry-page';

  static Widget forNewEntry() {
    return BlocProvider(
      create: (context) => BowelMovementEntryBloc.fromContext(context)..add(const CreateAndStreamBowelMovementEntry()),
      child: BowelMovementEntryPage(),
    );
  }

  static Widget forExistingEntry(BowelMovementEntry entry) {
    return BlocProvider(
      create: (context) => BowelMovementEntryBloc.fromContext(context)..add(StreamBowelMovementEntry(entry)),
      child: BowelMovementEntryPage(),
    );
  }

  @override
  State<BowelMovementEntryPage> createState() => _BowelMovementEntryPageState();
}

class _BowelMovementEntryPageState extends State<BowelMovementEntryPage> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BowelMovementEntryBloc, BowelMovementEntryState>(
      builder: builder,
      listener: listener,
      listenWhen: listenWhen,
    );
  }

  void listener(BuildContext context, BowelMovementEntryState state) {
    if (state is BowelMovementEntryLoaded) {
      _notesController.text = state.diaryEntry.notes ?? '';
    }
  }

  bool listenWhen(BowelMovementEntryState previousState, BowelMovementEntryState currentState) {
    return currentState is BowelMovementEntryLoaded && previousState is! BowelMovementEntryLoaded;
  }

  Widget builder(BuildContext context, BowelMovementEntryState state) {
    List<Widget> bmTiles(BowelMovementEntry entry) {
      return [
        DateTimeCard(
          dateTime: entry.datetime,
          onChanged: (value) {
            if (value != null) {
              context.read<BowelMovementEntryBloc>().add(UpdateBowelMovementEntryDateTime(value));
            }
          },
        ),
        BMVolumeCard(
          volume: entry.bowelMovement.volume,
          onChanged: (value) {
            context.read<BowelMovementEntryBloc>().add(UpdateVolume(value));
          },
        ),
        BMTypeCard(
          type: entry.bowelMovement.type,
          onChanged: (value) {
            context.read<BowelMovementEntryBloc>().add(UpdateType(value));
          },
        ),
        NotesCard(
          controller: _notesController,
          onChanged: (value) {
            context.read<BowelMovementEntryBloc>().add(UpdateBowelMovementEntryNotes(value));
          },
        ),
      ];
    }

    Widget buildBody(BowelMovementEntryState state) {
      if (state is BowelMovementEntryLoading) {
        return LoadingPage();
      }

      if (state is BowelMovementEntryLoaded) {
        final tiles = bmTiles(state.diaryEntry as BowelMovementEntry);
        return ListView.builder(
          itemCount: tiles.length,
          itemBuilder: (context, index) => Padding(padding: const EdgeInsets.all(1.0), child: tiles[index]),
          padding: const EdgeInsets.all(0.0),
        );
      }

      if (state is BowelMovementEntryError) {
        return ErrorPage(message: state.message);
      }

      return const ErrorPage();
    }

    return GLScaffold(
      appBar: GLAppBar(title: 'Bowel Movement'),
      body: buildBody(state),
    );
  }
}
