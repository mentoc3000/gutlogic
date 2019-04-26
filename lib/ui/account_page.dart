import 'package:flutter/material.dart';
import 'aws_login_example.dart';
import '../resources/user_service.dart';
import '../resources/aws_sig_v4_service.dart';

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

                    // get session credentials
                    final _userService = new UserService();
                    final credentials = await _userService.getCredentials();
                    final sigV4Service = new AwsSigV4Service(credentials);
                    final response = await sigV4Service.apiRequest('GET', '/say-hello');
                    
                    String message = response.body;
                    final snackBar = SnackBar(
                      content: Text(message),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () => Scaffold.of(context).removeCurrentSnackBar()
                      ),
                      duration: Duration(seconds: 30),
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
