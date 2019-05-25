import 'package:flutter/material.dart';
import 'package:gut_ai/blocs/symptom_type_bloc.dart';
import '../models/diary_entry.dart';
import '../widgets/datetime_view.dart';
import 'gutai_search_delegate.dart';

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
    return [
      DatetimeView(date: _symptomEntry.dateTime),
      buildSeveritySlider(),
    ];
  }

// TODO: make severity slider a class
  Widget buildSeveritySlider() {
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
          onChanged: (newValue) =>
              setState(() => _symptomEntry.symptom.severity = newValue),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: severityIndicators,
        ),
      ],
    );
  }

  void showFoodSearch(BuildContext context) {

    final symptomTypeBloc = SymptomTypeBloc();

    final onSelect = (symptomType) => this._symptomEntry.symptom.symptomType = symptomType;

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
        title:
            Text(_symptomEntry?.symptom?.symptomType?.name ?? 'Symptom'),
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
