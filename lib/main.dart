import 'package:flutter/material.dart';
import 'package:gi_bliss/mainTabs/MainTabs.dart';
import 'package:gi_bliss/account/Account.dart';
import 'package:gi_bliss/diary/Diary.dart';
import 'package:gi_bliss/foodSearch/FoodSearch.dart';
import 'package:gi_bliss/login/Login.dart';

void main() => runApp(GiBlissApp());

class GiBlissApp extends StatelessWidget {

  final routes = <String, WidgetBuilder> {
    Account.tag: (context) => Account(),
    Diary.tag: (context) => Diary(),
    FoodSearch.tag: (context) => FoodSearch()
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      routes: routes,
    );
  }
}
