import 'package:flutter/material.dart';
import 'package:gut_ai/pages/main_tabs.dart';
import 'package:gut_ai/pages/account_page.dart';
import 'package:gut_ai/pages/diary_page.dart';
import 'package:gut_ai/pages/food_search_page.dart';
// import 'package:gut_ai/pages/login_page.dart';
import 'package:gut_ai/pages/aws_login_example.dart';

void main() => runApp(GiBlissApp());

class GiBlissApp extends StatelessWidget {

  final routes = <String, WidgetBuilder> {
    AccountPage.tag: (context) => AccountPage(),
    DiaryPage.tag: (context) => DiaryPage(),
    FoodSearchPage.tag: (context) => FoodSearchPage(),
    Tabbed.tag: (context) => Tabbed()
    // MealEntryPage.tag: (context) => MealEntryPage(entry:)
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LoginScreen(),
      ),
      routes: routes,
    );
  }
}
