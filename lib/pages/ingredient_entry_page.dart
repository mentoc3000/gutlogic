import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/ingredient.dart';
import '../models/food.dart';
import '../models/quantity.dart';
import '../widgets/quantity_view.dart';
import '../blocs/food_bloc.dart';
import 'gutai_search_delegate.dart';

class IngredientEntryPage extends StatefulWidget {
  static String tag = 'ingredient-entry-page';

  final Ingredient ingredient;
  final void Function(Ingredient) onSave;

  IngredientEntryPage({this.ingredient, this.onSave});

  @override
  IngredientEntryPageState createState() => IngredientEntryPageState();
}

class IngredientEntryPageState extends State<IngredientEntryPage> {
  Food _food;
  Quantity _quantity;

  @override
  void initState() {
    super.initState();
    _food = widget.ingredient?.food ?? null;
    _quantity = widget.ingredient?.quantity ?? null;
  }

  @override
  void dispose() {
    if (_food != null && _quantity != null) {
      Ingredient ingredient = Ingredient(food: _food, quantity: _quantity);
      widget.onSave(ingredient);
    }
    super.dispose();
  }

  List<Widget> buildItems() {
    return [
      QuantityView(
        quantity: _quantity,
        onChanged: (newQuantity) {
          _quantity = newQuantity;
        },
      ),
    ];
  }

  void showFoodSearch(BuildContext context) {
    FoodBloc foodBloc = BlocProvider.of<FoodBloc>(context);

    final onSelect = (food) => this._food = food;

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
        title: Text(_food?.name ?? 'Ingredient'),
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
