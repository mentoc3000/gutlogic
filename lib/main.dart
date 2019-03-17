import 'package:flutter/material.dart';
import 'package:gi_bliss/mainTabs/MainTabs.dart';
import 'package:gi_bliss/account/Account.dart';
import 'package:gi_bliss/diary/Diary.dart';
import 'package:gi_bliss/foodSearch/FoodSearch.dart';
import 'package:gi_bliss/login/Login.dart';

void main() => runApp(GiBlissApp());

class GiBlissApp extends StatelessWidget {

  final routes = <String, WidgetBuilder> {
    AccountPage.tag: (context) => AccountPage(),
    DiaryPage.tag: (context) => DiaryPage(),
    FoodSearch.tag: (context) => FoodSearch(),
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
