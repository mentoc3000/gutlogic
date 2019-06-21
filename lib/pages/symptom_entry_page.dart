import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gut_ai/blocs/symptom_type_bloc.dart';
import 'package:gut_ai/models/symptom_type.dart';
import '../models/diary_entry.dart';
import '../widgets/datetime_view.dart';
import 'gutai_search_delegate.dart';
import '../widgets/notes_tile.dart';
import '../widgets/placeholder_widget.dart';
import '../blocs/diary_entry_bloc.dart';
import '../blocs/database_event.dart';

class SymptomEntryPage extends StatefulWidget {
  static String tag = 'symptom-entry-page';

  final SymptomEntry entry;

  SymptomEntryPage({this.entry});

  @override
  SymptomEntryPageState createState() => SymptomEntryPageState();
}

class SymptomEntryPageState extends State<SymptomEntryPage> {
  SymptomEntry _symptomEntry;

  @override
  void initState() {
    super.initState();
    _symptomEntry = widget.entry;
  }

  List<Widget> buildItems() {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    return [
      DatetimeView(
        date: _symptomEntry.dateTime,
        onChanged: (dateTime) {
          _symptomEntry = _symptomEntry.rebuild((b) => b..dateTime = dateTime);
          diaryEntryBloc.dispatch(Upsert(_symptomEntry));
        },
      ),
      buildSeveritySlider(),
      NotesTile(notes: _symptomEntry.notes),
    ];
  }

// TODO: make severity slider a class
  Widget buildSeveritySlider() {
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);
    List<SeverityIndicator> severityIndicators = [
      SeverityIndicator(
        image: Image.asset(
          'assets/pain_scale/no_pain.jpg',
          scale: 5,
        ),
        label: 'No Pain',
      ),
      SeverityIndicator(
        image: Image.asset(
          'assets/pain_scale/discomfort.jpg',
          scale: 5,
        ),
        label: 'Discomfort',
      ),
      SeverityIndicator(
        image: Image.asset(
          'assets/pain_scale/distressing.jpg',
          scale: 5,
        ),
        label: 'Distressing',
      ),
      SeverityIndicator(
        image: Image.asset(
          'assets/pain_scale/intense.jpg',
          scale: 5,
        ),
        label: 'Intense',
      ),
      SeverityIndicator(
        image: Image.asset(
          'assets/pain_scale/horrible.jpg',
          scale: 5,
        ),
        label: 'Horrible',
      ),
      SeverityIndicator(
        image: Image.asset(
          'assets/pain_scale/unspeakable.jpg',
          scale: 5,
        ),
        label: 'Unspeakable',
      ),
    ];

    return Column(
      children: [
        Slider(
            min: 0,
            max: 10,
            divisions: 11,
            value: _symptomEntry.symptom.severity,
            onChanged: (newValue) {
              setState(() => _symptomEntry =
                  _symptomEntry.rebuild((b) => b..symptom.severity = newValue));
              diaryEntryBloc.dispatch(Upsert(_symptomEntry));
            }
            // setState(() => _symptomEntry.symptom.severity = newValue),
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: severityIndicators,
        ),
      ],
    );
  }

  void showFoodSearch(BuildContext context) {
    final symptomTypeBloc = BlocProvider.of<SymptomTypeBloc>(context);
    DiaryEntryBloc diaryEntryBloc = BlocProvider.of<DiaryEntryBloc>(context);

    final void Function(SymptomType) onSelect = (symptomType) {
      setState(() => _symptomEntry = _symptomEntry
          .rebuild((b) => b..symptom.symptomType = symptomType.toBuilder()));
      diaryEntryBloc.dispatch(Upsert(_symptomEntry));
    };

    showSearch(
      context: context,
      delegate: GutAiSearchDelegate(
        searchableBloc: symptomTypeBloc,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = buildItems();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_symptomEntry?.symptom?.symptomType?.name ?? 'Symptom'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showFoodSearch(context),
          ),
        ],
      ),
      body: Form(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              Padding(padding: EdgeInsets.all(1.0), child: items[index]),
          padding: EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}

class SeverityIndicator extends StatelessWidget {
  final Image image;
  final String label;

  SeverityIndicator({this.image, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[image, Text(label)],
    );
  }
}
