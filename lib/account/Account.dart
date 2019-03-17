import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  static String tag = 'account-page';
  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Account"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(title: Text("Placeholder"),)
        ],
      ),
    );
  }
}
