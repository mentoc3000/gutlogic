import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/quantity_view.dart';
import '../blocs/food_bloc.dart';
import '../models/food.dart';
import '../resources/app_sync_service.dart';
import '../resources/user_service.dart';

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

  List<Widget> buildItems() {
    return [
      QuantityView(
        quantity: _ingredient.quantity,
      ),
    ];
  }

  void showFoodSearch() {
    showSearch(
      context: context,
      delegate: IngredientSearchDelegate(onSelect: (food) {
        this._ingredient = Ingredient(food: food);
      }),
    );
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
              onPressed: showFoodSearch,
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
            itemBuilder: (context, index) =>
                Padding(padding: EdgeInsets.all(1.0), child: items[index]),
            padding: EdgeInsets.all(0.0),
          ),
        ));
  }
}

class IngredientSearchDelegate extends SearchDelegate {
  FoodBloc _foodBloc;
  final void Function(Food) onSelect;

  IngredientSearchDelegate({this.onSelect}) {
    final userService = UserService();
    final session = userService.getSession();
    AppSyncService appSyncService = AppSyncService(session);
    _foodBloc = FoodBloc(appSyncService);
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
    _foodBloc.dispose();
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
    _foodBloc.fetchQuery(query);

    return Column(
      children: <Widget>[
        //Build the results based on the searchResults stream in the searchBloc
        StreamBuilder(
          stream: _foodBloc.allFoods,
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
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var result = results[index];
                  return ListTile(
                      title: Text(result.name),
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
