import 'package:flutter/material.dart';
import 'package:gi_bliss/mainTabs/MainTabs.dart';
import 'package:gi_bliss/account/account_page.dart';
import 'package:gi_bliss/diary/diary_page.dart';
import 'package:gi_bliss/food_search/food_search_page.dart';
import 'package:gi_bliss/login/Login.dart';

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
