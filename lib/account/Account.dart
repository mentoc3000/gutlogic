import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  static String tag = 'account-page';
  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {

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
