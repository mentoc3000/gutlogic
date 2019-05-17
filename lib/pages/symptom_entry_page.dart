import 'package:flutter/material.dart';
import 'package:gut_ai/blocs/symptom_type_bloc.dart';
import '../models/diary_entry.dart';
import '../models/symptom.dart';
import '../widgets/placeholder_widget.dart';
import '../widgets/datetime_view.dart';

class SymptomEntryPage extends StatefulWidget {
  static String tag = 'symptom-entry-page';

  final void Function(SymptomEntry) onSaved;
  final SymptomEntry entry;

  SymptomEntryPage({this.entry, this.onSaved});

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
    ];
  }

  void showFoodSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: SymptomSearchDelegate(onSelect: (symptomType) {
        this._symptomEntry.symptom.symptomType = symptomType;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = buildItems();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(SymptomName[_symptomEntry?.symptom?.symptomType] ?? 'Symptom'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showFoodSearch(context),
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onSaved(_symptomEntry);
              Navigator.of(context).pop();
            },
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

class SymptomSearchDelegate extends SearchDelegate {
  SymptomTypeBloc _symptomTypeBloc;
  final void Function(SymptomType) onSelect;

  SymptomSearchDelegate({this.onSelect}) {
    _symptomTypeBloc = SymptomTypeBloc();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  closeSearch(BuildContext context) {
    _symptomTypeBloc.dispose();
    close(context, null);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => closeSearch(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // if (query.length < 3) {
    //   return Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       Center(
    //         child: Text(
    //           "Search term must be longer than two letters.",
    //         ),
    //       )
    //     ],
    //   );
    // }

    // //Add the search term to the searchBloc.
    // //The Bloc will then handle the searching and add the results to the searchResults stream.
    // //This is the equivalent of submitting the search term to whatever search service you are using
    // InheritedBlocs.of(context)
    //     .searchBloc
    //     .searchTerm
    //     .add(query);
    _symptomTypeBloc.fetchQuery(query);

    return Column(
      children: <Widget>[
        //Build the results based on the searchResults stream in the searchBloc
        StreamBuilder(
          stream: _symptomTypeBloc.all,
          builder: (context, AsyncSnapshot<List<SymptomType>> snapshot) {
            if (!snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                ],
              );
            } else if (snapshot.data.length == 0) {
              return Column(
                children: <Widget>[
                  Text(
                    "No Results Found.",
                  ),
                ],
              );
            } else {
              var results = snapshot.data;
              return ListView.builder(
                itemCount: results.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var result = results[index];
                  return ListTile(
                      title: Text(SymptomName[result]),
                      onTap: () {
                        this.onSelect(result);
                        closeSearch(context);
                      });
                },
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }
}
