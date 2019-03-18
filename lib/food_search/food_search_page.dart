import 'package:flutter/material.dart';
import 'package:gi_bliss/helpers/placeholder_widget.dart';
import 'package:gi_bliss/model/food.dart';
import 'package:gi_bliss/model/food_list.dart';
import 'package:gi_bliss/helpers/dummy_data.dart';
import 'food_card.dart';

class FoodSearchPage extends StatefulWidget {
  static String tag = 'foodsearch-page';
  @override
  _FoodSearchPageState createState() {
    return _FoodSearchPageState();
  }
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  static String _title = "Food Search";
  Widget _appBarTitle = new Text(_title);
  final TextEditingController _filter = new TextEditingController();
  Icon _searchIcon = new Icon(Icons.search);
  String _searchText = "";
  FoodList _foods = new FoodList();
  FoodList _filteredFoods = new FoodList();

  @override
  void initState() {
    super.initState();

    _foods.foods = new List();
    _filteredFoods.foods = new List();

    _getFoods();
  }

  void _getFoods() {
    FoodList foods = Dummy.foodList;
    setState(() {
      for (Food food in foods.foods) {
        this._foods.foods.add(food);
        this._filteredFoods.foods.add(food);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      backgroundColor: Colors.white,
      body: _buildList(context),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (!(_searchText.isEmpty)) {
      _filteredFoods.foods = new List();
      for (int i = 0; i < _foods.foods.length; i++) {
        if (_foods.foods[i].name
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          _filteredFoods.foods.add(_foods.foods[i]);
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: this
          ._filteredFoods
          .foods
          .map((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, Food food) => new FoodCard(food);

  _FoodSearchPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _resetFoods();
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  void _resetFoods() {
    this._filteredFoods.foods = new List();
    for (Food food in _foods.foods) {
      this._filteredFoods.foods.add(food);
    }
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          style: new TextStyle(color: Colors.white),
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white),
            fillColor: Colors.white,
            hintText: 'Search by name',
            hintStyle: TextStyle(color: Colors.white),
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text(_title);
        _filter.clear();
      }
    });
  }
}
