import 'package:flutter/material.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/models/ingredient.dart';
import 'quantity_view.dart';
import 'package:gut_ai/blocs/food_bloc.dart';
import 'package:gut_ai/models/food.dart';

class IngredientEntryPage extends StatefulWidget {
  static String tag = 'ingredient-entry-page';

  final void Function(Ingredient) onSaved;
  final Ingredient ingredient;

  IngredientEntryPage({this.ingredient, this.onSaved});

  @override
  IngredientEntryPageState createState() => IngredientEntryPageState();
}

class IngredientEntryPageState extends State<IngredientEntryPage> {

  Ingredient _ingredient;

  @override
  void initState() {
    super.initState();
    _ingredient = Ingredient.copy(widget.ingredient);
  }
  
  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  List<Widget> buildItems() {
    return [
      QuantityView(quantity: _ingredient.quantity,),
    ];
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> items = buildItems();    

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_ingredient?.food?.name ?? 'Ingredient'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: IngredientSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onSaved(_ingredient);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Form(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.all(1.0),
            child: items[index]
          ),
          padding: EdgeInsets.all(0.0),
        ),
      )
    );
  }
}

class IngredientSearchDelegate extends SearchDelegate {
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

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
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
    bloc.fetchQuery(query);

    return Column(
      children: <Widget>[
        //Build the results based on the searchResults stream in the searchBloc
        StreamBuilder(
          stream: bloc.allFoods,
          builder: (context, AsyncSnapshot<List<Food>> snapshot) {
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
                itemBuilder: (context, index) {
                  var result = results[index];
                  return ListTile(
                    title: Text(result.name),
                  );
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