import 'package:flutter/material.dart';
import 'package:gut_ai/main_tabs.dart';
import 'package:gut_ai/account/account_page.dart';
import 'package:gut_ai/diary/diary_page.dart';
import 'package:gut_ai/food_search/food_search_page.dart';
import 'package:gut_ai/login/login_page.dart';

void main() => runApp(GiBlissApp());

class GiBlissApp extends StatelessWidget {

  final routes = <String, WidgetBuilder> {
    AccountPage.tag: (context) => AccountPage(),
    DiaryPage.tag: (context) => DiaryPage(),
    FoodSearchPage.tag: (context) => FoodSearchPage(),
    MainTabs.tag: (context) => MainTabs()
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      routes: routes,
    );
  }
}
