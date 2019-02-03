import 'package:flutter/material.dart';
import 'package:gi_bliss/helpers/PlaceholderWidget.dart';

class MainTabs extends StatefulWidget {
  @override
  MainTabsState createState() => new MainTabsState();
}

class MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.white),
    PlaceholderWidget(Colors.blue),
    PlaceholderWidget(Colors.red),
    PlaceholderWidget(Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('My Flutter App'),
     ),
     body: _children[_currentIndex],
     bottomNavigationBar: BottomNavigationBar(
       currentIndex: 0, // this will be set when a new tab is tapped
       onTap: tabWasTapped,
       items: [
         BottomNavigationBarItem(
           icon: new Icon(Icons.search),
           title: new Text('Search'),
         ),
         BottomNavigationBarItem(
           icon: new Icon(Icons.subject),
           title: new Text('Diary'),
         ),
        //  BottomNavigationBarItem(
        //    icon: new Icon(Icons.mail),
        //    title: new Text('Recipes'),
        //  ),
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