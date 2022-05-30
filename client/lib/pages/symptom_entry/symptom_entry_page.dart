import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/symptom_entry/symptom_entry.dart';
import '../../blocs/symptom_type/symptom_type.dart';
import '../../models/diary_entry/symptom_entry.dart';
import '../../models/severity.dart';
import '../../models/symptom_type.dart';
import '../../widgets/cards/datetime_card.dart';
import '../../widgets/cards/notes_card.dart';
import '../../widgets/floating_action_buttons/search_floating_action_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../error_page.dart';
import '../loading_page.dart';
import '../search_delegate/symptom_type_search_delegate.dart';
import 'widgets/severity_card.dart';

class SymptomEntryPage extends StatefulWidget {
  static String tag = 'symptom-entry-page';

  static Widget forNewEntryFrom(SymptomType symptomType) {
    return BlocProvider(
      create: (context) => SymptomEntryBloc.fromContext(context)..add(CreateFromAndStreamSymptomEntry(symptomType)),
      child: SymptomEntryPage(),
    );
  }

  static Widget forExistingEntry(SymptomEntry entry) {
    return BlocProvider(
      create: (context) => SymptomEntryBloc.fromContext(context)..add(StreamSymptomEntry(entry)),
      child: SymptomEntryPage(),
    );
  }

  @override
  State<SymptomEntryPage> createState() => _SymptomEntryPageState();
}

class _SymptomEntryPageState extends State<SymptomEntryPage> {
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
    return BlocConsumer<SymptomEntryBloc, SymptomEntryState>(
      builder: builder,
      listener: listener,
      listenWhen: listenWhen,
    );
  }

  void listener(BuildContext context, SymptomEntryState state) {
    if (state is SymptomEntryLoaded) {
      _notesController.text = state.diaryEntry.notes ?? '';
    }
  }

  bool listenWhen(SymptomEntryState previousState, SymptomEntryState currentState) {
    return currentState is SymptomEntryLoaded && previousState is! SymptomEntryLoaded;
  }

  Widget builder(BuildContext context, SymptomEntryState state) {
    List<Widget> buildItems(BuildContext context, SymptomEntry entry) {
      return [
        DateTimeCard(
          dateTime: entry.datetime,
          onChanged: (DateTime? datetime) {
            if (datetime == null) return;
            context.read<SymptomEntryBloc>().add(UpdateSymptomEntryDateTime(datetime));
          },
        ),
        SeverityCard(
          severity: entry.symptom.severity,
          onChanged: (Severity newValue) => context.read<SymptomEntryBloc>().add(UpdateSeverity(newValue)),
        ),
        NotesCard(
          controller: _notesController,
          onChanged: (String notes) {
            context.read<SymptomEntryBloc>().add(UpdateSymptomEntryNotes(notes));
          },
        ),
      ];
    }

    void showSymptomTypeSearch(BuildContext context, SymptomEntry entry) {
      final symptomTypeBloc = BlocProvider.of<SymptomTypeBloc>(context);

      showSearch(
        context: context,
        delegate: SymptomTypeSearchDelegate(
          symptomTypeBloc: symptomTypeBloc,
          onSelect: (symptomType) {
            context.read<SymptomEntryBloc>().add(UpdateSymptomType(symptomType));
          },
        ),
      );
    }

    Widget buildPage(SymptomEntryState state) {
      final defaultAppBar = GLAppBar(title: 'Symptom');

      if (state is SymptomEntryLoading) {
        return GLScaffold(
          appBar: defaultAppBar,
          body: LoadingPage(),
        );
      }

      if (state is SymptomEntryLoaded) {
        final entry = state.diaryEntry as SymptomEntry;
        final items = buildItems(context, entry);

        final symptomName = entry.symptom.symptomType.name == '' ? 'Symptom' : entry.symptom.symptomType.name;
        return GLScaffold(
          appBar: GLAppBar(title: symptomName),
          body: Form(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(padding: const EdgeInsets.all(1.0), child: items[index]);
              },
              padding: const EdgeInsets.all(0.0),
            ),
          ),
          floatingActionButton: SearchFloatingActionButton(
            onPressed: () => showSymptomTypeSearch(context, entry),
          ),
        );
      }

      if (state is SymptomEntryError) {
        return GLScaffold(
          appBar: defaultAppBar,
          body: ErrorPage(message: state.message),
        );
      }

      return GLScaffold(
        appBar: defaultAppBar,
        body: const ErrorPage(),
      );
    }

    return buildPage(state);
  }
}
