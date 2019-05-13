
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'account_page.dart';
import 'food_search_page.dart';
import 'diary_page.dart';
import '../widgets/placeholder_widget.dart';

class CustomTab extends StatelessWidget {
  final Widget child;
  BuildContext tabContext;

  CustomTab({@required this.child});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (BuildContext context) {
        tabContext = context;
        return child;
      },
    );
  }
}


class Tabbed extends StatefulWidget {
  static String tag = 'tabbed-page';
  @override
  _TabbedState createState() => _TabbedState();
}

class _TabbedState extends State<Tabbed> {
  int _currentTab = 0;

  final List<CustomTab> tabs = <CustomTab>[
    CustomTab(
      child: DiaryPage(),
    ),
    CustomTab(
      child: FoodSearchPage(),
    ),
    CustomTab(
      child: PlaceholderWidget(Colors.red),
    ),
    CustomTab(
      child: AccountPage(),
    ),
  ];

  Future<Null> _setTab(int index) async {
    if (_currentTab == index) {
      if (Navigator.of(tabs[index].tabContext).canPop()) {
        Navigator.of(tabs[index].tabContext)
            .popUntil((Route<dynamic> r) => r.isFirst);
      }
      return;
    }
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          _buildStack(),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildStack() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: IndexedStack(
          sizing: StackFit.expand,
          index: _currentTab,
          children: tabs,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(color: Color.fromRGBO(58, 66, 86, 0.3)),
          ),
        ),
        height: 55.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              iconSize: 30.0,
              color: _currentTab == 0
                  ? Color.fromRGBO(58, 66, 86, 1.0)
                  : Color.fromRGBO(58, 66, 86, 0.3),
              icon: const Icon(Icons.subject),
              onPressed: () {
                _setTab(0);
              },
            ),
            IconButton(
              iconSize: 30.0,
              color: _currentTab == 1
                  ? Color.fromRGBO(58, 66, 86, 1.0)
                  : Color.fromRGBO(58, 66, 86, 0.3),
              icon: const Icon(Icons.search),
              onPressed: () {
                _setTab(1);
              },
            ),
            IconButton(
              iconSize: 30.0,
              color: _currentTab == 2
                  ? Color.fromRGBO(58, 66, 86, 1.0)
                  : Color.fromRGBO(58, 66, 86, 0.3),
              icon: const Icon(Icons.web_asset),
              onPressed: () {
                _setTab(2);
              },
            ),
            IconButton(
              iconSize: 30.0,
              color: _currentTab == 3
                  ? Color.fromRGBO(58, 66, 86, 1.0)
                  : Color.fromRGBO(58, 66, 86, 0.3),
              icon: const Icon(Icons.person),
              onPressed: () {
                _setTab(3);
              },
            )
          ],
        ),
      ),
    );
  }
}
