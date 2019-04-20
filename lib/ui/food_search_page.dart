import 'package:flutter/material.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/resources/dummy_data.dart';
import 'item_tile.dart';

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
  List<Food> _foods = [];
  List<Food> _filteredFoods = [];

  @override
  void initState() {
    super.initState();

    _foods = new List();
    _filteredFoods = new List();

    _getFoods();
  }

  void _getFoods() {
    List<Food> foods = Dummy.foodList;
    setState(() {
      for (Food food in foods) {
        this._foods.add(food);
        this._filteredFoods.add(food);
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
      _filteredFoods = new List();
      for (int i = 0; i < _foods.length; i++) {
        if (_foods[i].name
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          _filteredFoods.add(_foods[i]);
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: this
          ._filteredFoods
          .map((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, Food food) => new FoodListTile(food: food);

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
    this._filteredFoods = new List();
    for (Food food in _foods) {
      this._filteredFoods.add(food);
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
