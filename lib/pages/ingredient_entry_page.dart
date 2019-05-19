import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/quantity_view.dart';
import '../blocs/food_bloc.dart';
import '../models/food.dart';
import '../resources/app_sync_service.dart';
import '../resources/user_service.dart';
import 'gutai_search_delegate.dart';

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

  void showFoodSearch(BuildContext context) {
    final userService = UserService();
    final session = userService.getSession();
    AppSyncService appSyncService = AppSyncService(session);
    FoodBloc foodBloc = FoodBloc(appSyncService);

    final onSelect = (food) => this._ingredient = Ingredient(food: food);

    showSearch(
      context: context,
      delegate: GutAiSearchDelegate(
        searchableBloc: foodBloc,
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
        title: Text(_ingredient?.food?.name ?? 'Ingredient'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showFoodSearch(context),
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
      ),
    );
  }
}
