import 'package:flutter/material.dart';
import 'package:gi_bliss/helpers/PlaceholderWidget.dart';
import 'package:gi_bliss/model/Food.dart';
import 'package:gi_bliss/model/FoodList.dart';
import 'package:gi_bliss/helpers/DummyFoods.dart';

class FoodSearch extends StatefulWidget {
  @override
  _FoodSearchState createState() {
    return _FoodSearchState();
  }
}

class _FoodSearchState extends State<FoodSearch> {

  Widget _appBarTitle = new Text("Food Search");
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
    FoodList foods = DummyFoods.dummyFoods;
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
      backgroundColor: Colors.blueGrey,
      body: _buildList(context),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      elevation: 0.1,
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        // onPressed: _searchPressed,
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (!(_searchText.isEmpty)) {
      _filteredFoods.foods = new List();
      for (int i = 0; i < _foods.foods.length; i++) {
        if (_foods.foods[i].name.toLowerCase().contains(_searchText.toLowerCase())) {
          _filteredFoods.foods.add(_foods.foods[i]);
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: this._filteredFoods.foods.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, Food food) { 
    return Card(
      key: ValueKey(food.name),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, 0.9)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            food.name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
          subtitle: Row(
            children: <Widget>[
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: food.irritants.join(', '),
                        style: TextStyle(color: Colors.white)
                      ),
                      maxLines: 3,
                      softWrap: true,
                    )
                  ]
                )
              )
            ]
          ),
          trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
          // onTap: () {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => new DetailPage(food: food)));
          // }
        )
      )
    );
  }


}