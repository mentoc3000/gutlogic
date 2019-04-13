import 'package:flutter/material.dart';
import 'package:gut_ai/login/aws_login_example.dart';
import 'package:gut_ai/backend/user_service.dart';

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
      body: Builder(
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              ListTile(title: Text("Placeholder"),),
              new Divider(),
              new Center(
                child: new InkWell(
                  child: new Text(
                    'Say Hello',
                    style: new TextStyle(color: Colors.greenAccent),
                  ),
                  onTap: () async {
                    String message = 'Hi there!';
                    final snackBar = SnackBar(
                      content: Text(message),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () => Scaffold.of(context).removeCurrentSnackBar()
                      ),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                ),
              ),
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
          );
        }
      )
    );
  }
}
