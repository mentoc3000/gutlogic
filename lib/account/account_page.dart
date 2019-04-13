import 'package:flutter/material.dart';
import 'package:gut_ai/login/aws_login_example.dart';
import 'package:gut_ai/backend/aws_cognito.dart';

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
          ListTile(title: Text("Placeholder"),),
          new Divider(),
          new Center(
            child: new InkWell(
              child: new Text(
                'Logout',
                style: new TextStyle(color: Colors.blueAccent),
              ),
              onTap: () async {
                final _userService = new UserService();
                await _userService.signOut();
                Navigator.of(context, rootNavigator: true)
                  ..pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
