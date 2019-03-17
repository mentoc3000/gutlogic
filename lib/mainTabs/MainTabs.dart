import 'package:flutter/material.dart';
import 'package:gi_bliss/account/account_page.dart';
import 'package:gi_bliss/food_search/food_search_page.dart';
import 'package:gi_bliss/diary/diary_page.dart';
import 'package:gi_bliss/helpers/placeholder_widget.dart';

class MainTabs extends StatefulWidget {
  static String tag = 'maintabs-page';
  @override
  MainTabsState createState() => new MainTabsState();
}

class MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    FoodSearchPage(),
    DiaryPage(),
    PlaceholderWidget(Colors.red),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        type: BottomNavigationBarType.fixed,
        onTap: tabWasTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: new Icon(Icons.search),
            title: new Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.subject),
            title: new Text('Diary'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.web_asset),
            title: new Text('Recipes'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile')
          )
        ],
      ),
    );
  }

  void tabWasTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}