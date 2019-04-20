import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gut_ai/resources/user_service.dart';
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'main_tabs.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => new _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  User _user = new User();
  final userService = new UserService();

  void submit(BuildContext context) async {
    _formKey.currentState.save();

    String message;
    bool signUpSuccess = false;
    try {
      _user = await userService.signUp(_user.email, _user.password, _user.name);
      signUpSuccess = true;
      message = 'User sign up successful!';
    } on CognitoClientException catch (e) {
      if (e.code == 'UsernameExistsException' ||
          e.code == 'InvalidParameterException' ||
          e.code == 'ResourceNotFoundException') {
        message = e.message;
      } else {
        message = 'Unknown client error occurred';
      }
    } catch (e) {
      message = 'Unknown error occurred';
    }

    final snackBar = new SnackBar(
      content: new Text(message),
      action: new SnackBarAction(
        label: 'OK',
        onPressed: () {
          if (signUpSuccess) {
            Navigator.pop(context);
            if (!_user.confirmed) {
              Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) =>
                        new ConfirmationScreen(email: _user.email)),
              );
            }
          }
        },
      ),
      duration: new Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Sign Up'),
      ),
      body: new Builder(
        builder: (BuildContext context) {
          return new Container(
            child: new Form(
              key: _formKey,
              child: new ListView(
                children: <Widget>[
                  new ListTile(
                    leading: const Icon(Icons.account_box),
                    title: new TextFormField(
                      decoration: new InputDecoration(labelText: 'Name'),
                      onSaved: (String name) {
                        _user.name = name;
                      },
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.email),
                    title: new TextFormField(
                      decoration: new InputDecoration(
                          hintText: 'example@inspire.my', labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (String email) {
                        _user.email = email;
                      },
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.lock),
                    title: new TextFormField(
                      decoration: new InputDecoration(
                        hintText: 'Password!',
                      ),
                      obscureText: true,
                      onSaved: (String password) {
                        _user.password = password;
                      },
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.all(20.0),
                    width: screenSize.width,
                    child: new RaisedButton(
                      child: new Text(
                        'Sign Up',
                        style: new TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        submit(context);
                      },
                      color: Colors.blue,
                    ),
                    margin: new EdgeInsets.only(
                      top: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ConfirmationScreen extends StatefulWidget {
  ConfirmationScreen({Key key, this.email}) : super(key: key);

  final String email;

  @override
  _ConfirmationScreenState createState() => new _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String confirmationCode;
  User _user = new User();
  final _userService = new UserService();

  _submit(BuildContext context) async {
    _formKey.currentState.save();
    bool accountConfirmed;
    String message;
    try {
      accountConfirmed =
          await _userService.confirmAccount(_user.email, confirmationCode);
      message = 'Account successfully confirmed!';
    } on CognitoClientException catch (e) {
      if (e.code == 'InvalidParameterException' ||
          e.code == 'CodeMismatchException' ||
          e.code == 'NotAuthorizedException' ||
          e.code == 'UserNotFoundException' ||
          e.code == 'ResourceNotFoundException') {
        message = e.message;
      } else {
        message = 'Unknown client error occurred';
      }
    } catch (e) {
      message = 'Unknown error occurred';
    }

    final snackBar = new SnackBar(
      content: new Text(message),
      action: new SnackBarAction(
        label: 'OK',
        onPressed: () {
          if (accountConfirmed) {
            Navigator.pop(context);
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new LoginScreen(email: _user.email)),
            );
          }
        },
      ),
      duration: new Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _resendConfirmation(BuildContext context) async {
    _formKey.currentState.save();
    String message;
    try {
      await _userService.resendConfirmationCode(_user.email);
      message = 'Confirmation code sent to ${_user.email}!';
    } on CognitoClientException catch (e) {
      if (e.code == 'LimitExceededException' ||
          e.code == 'InvalidParameterException' ||
          e.code == 'ResourceNotFoundException') {
        message = e.message;
      } else {
        message = 'Unknown client error occurred';
      }
    } catch (e) {
      message = 'Unknown error occurred';
    }

    final snackBar = new SnackBar(
      content: new Text(message),
      action: new SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
      duration: new Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Confirm Account'),
      ),
      body: new Builder(
          builder: (BuildContext context) => new Container(
                child: new Form(
                  key: _formKey,
                  child: new ListView(
                    children: <Widget>[
                      new ListTile(
                        leading: const Icon(Icons.email),
                        title: new TextFormField(
                          initialValue: widget.email,
                          decoration: new InputDecoration(
                              hintText: 'example@inspire.my',
                              labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (String email) {
                            _user.email = email;
                          },
                        ),
                      ),
                      new ListTile(
                        leading: const Icon(Icons.lock),
                        title: new TextFormField(
                          decoration: new InputDecoration(
                              labelText: 'Confirmation Code'),
                          onSaved: (String code) {
                            confirmationCode = code;
                          },
                        ),
                      ),
                      new Container(
                        padding: new EdgeInsets.all(20.0),
                        width: screenSize.width,
                        child: new RaisedButton(
                          child: new Text(
                            'Submit',
                            style: new TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _submit(context);
                          },
                          color: Colors.blue,
                        ),
                        margin: new EdgeInsets.only(
                          top: 10.0,
                        ),
                      ),
                      new Center(
                        child: new InkWell(
                          child: new Text(
                            'Resend Confirmation Code',
                            style: new TextStyle(color: Colors.blueAccent),
                          ),
                          onTap: () {
                            _resendConfirmation(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )),
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.email}) : super(key: key);

  final String email;

  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _userService = new UserService();
  User _user = new User();
  bool _isAuthenticated = false;

  Future<UserService> _getValues() async {
    _isAuthenticated = await _userService.checkAuthenticated();
    return _userService;
  }

  submit(BuildContext context) async {
    _formKey.currentState.save();
    String message;
    try {
      _user = await _userService.login(_user.email, _user.password);
      message = 'User sucessfully logged in!';
      if (!_user.confirmed) {
        message = 'Please confirm user account';
      }
    } on CognitoClientException catch (e) {
      if (e.code == 'InvalidParameterException' ||
          e.code == 'NotAuthorizedException' ||
          e.code == 'UserNotFoundException' ||
          e.code == 'ResourceNotFoundException') {
        message = e.message;
      } else {
        message = 'An unknown client error occured';
      }
    } catch (e) {
      print(e);
      message = 'An unknown error occurred';
    }
    final snackBar = new SnackBar(
      content: new Text(message),
      action: new SnackBarAction(
        label: 'OK',
        onPressed: () async {
          if (_user.hasAccess) {
            if (!_user.confirmed) {
              Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) =>
                        new ConfirmationScreen(email: _user.email)),
              );
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => Tabbed()
              ));
            }
          }
        },
      ),
      duration: new Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: _getValues(),
        builder: (context, AsyncSnapshot<UserService> snapshot) {
          if (snapshot.hasData) {
            if (_isAuthenticated) {
              return new Tabbed();
            }
            final Size screenSize = MediaQuery.of(context).size;
            return new Scaffold(
              appBar: new AppBar(
                title: new Text('Login'),
              ),
              body: new Builder(
                builder: (BuildContext context) {
                  return new Container(
                    child: new Form(
                      key: _formKey,
                      child: new ListView(
                        children: <Widget>[
                          new ListTile(
                            leading: const Icon(Icons.email),
                            title: new TextFormField(
                              initialValue: widget.email,
                              decoration: new InputDecoration(
                                  hintText: 'example@inspire.my',
                                  labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (String email) {
                                _user.email = email;
                              },
                            ),
                          ),
                          new ListTile(
                            leading: const Icon(Icons.lock),
                            title: new TextFormField(
                              decoration:
                                  new InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              onSaved: (String password) {
                                _user.password = password;
                              },
                            ),
                          ),
                          new Container(
                            padding: new EdgeInsets.all(20.0),
                            width: screenSize.width,
                            child: new RaisedButton(
                              child: new Text(
                                'Login',
                                style: new TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                submit(context);
                              },
                              color: Colors.blue,
                            ),
                            margin: new EdgeInsets.only(
                              top: 10.0,
                            ),
                          ),
                          new Container(
                            padding: new EdgeInsets.all(20.0),
                            width: screenSize.width,
                            child: new RaisedButton(
                              child: new Text(
                                'Sign Up',
                                style: new TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                              },
                              color: Colors.grey,
                            ),
                            margin: new EdgeInsets.only(
                              top: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return new Scaffold(
              appBar: new AppBar(title: new Text('Loading...')));
        });
  }
}

// class SecureCounterScreen extends StatefulWidget {
//   SecureCounterScreen({Key key}) : super(key: key);

//   @override
//   _SecureCounterScreenState createState() => new _SecureCounterScreenState();
// }

// class _SecureCounterScreenState extends State<SecureCounterScreen> {
//   final _userService = new UserService();
//   CounterService _counterService;
//   AwsSigV4Client _awsSigV4Client;
//   User _user = new User();
//   Counter _counter = new Counter(0);
//   bool _isAuthenticated = false;

//   void _incrementCounter() async {
//     final counter = await _counterService.incrementCounter();
//     setState(() {
//       _counter = counter;
//     });
//   }

//   Future<UserService> _getValues(BuildContext context) async {
//     try {
//       _isAuthenticated = await _userService.checkAuthenticated();
//       if (_isAuthenticated) {
//         // get user attributes from cognito
//         _user = await _userService.getCurrentUser();

//         // get session credentials
//         final credentials = await _userService.getCredentials();
//         _awsSigV4Client = new AwsSigV4Client(
//             credentials.accessKeyId, credentials.secretAccessKey, endpoint,
//             region: region, sessionToken: credentials.sessionToken);

//         // get previous count
//         _counterService = new CounterService(_awsSigV4Client);
//         _counter = await _counterService.getCounter();
//       }
//       return _userService;
//     } on CognitoClientException catch (e) {
//       if (e.code == 'NotAuthorizedException') {
//         await _userService.signOut();
//         Navigator.pop(context);
//       }
//       throw e;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new FutureBuilder(
//         future: _getValues(context),
//         builder: (context, AsyncSnapshot<UserService> snapshot) {
//           if (snapshot.hasData) {
//             if (!_isAuthenticated) {
//               return new LoginScreen();
//             }

//             return new Scaffold(
//               appBar: new AppBar(
//                 title: new Text('Secure Counter'),
//               ),
//               body: new Center(
//                 child: new Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     new Text(
//                       'Welcome ${_user.name}!',
//                       style: Theme.of(context).textTheme.display1,
//                     ),
//                     new Divider(),
//                     new Text(
//                       'You have pushed the button this many times:',
//                     ),
//                     new Text(
//                       '${_counter.count}',
//                       style: Theme.of(context).textTheme.display1,
//                     ),
//                     new Divider(),
//                     new Center(
//                       child: new InkWell(
//                         child: new Text(
//                           'Logout',
//                           style: new TextStyle(color: Colors.blueAccent),
//                         ),
//                         onTap: () {
//                           _userService.signOut();
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               floatingActionButton: new FloatingActionButton(
//                 onPressed: () {
//                   if (snapshot.hasData) {
//                     _incrementCounter();
//                   }
//                 },
//                 tooltip: 'Increment',
//                 child: new Icon(Icons.add),
//               ),
//             );
//           }
//           return new Scaffold(
//               appBar: new AppBar(title: new Text('Loading...')));
//         });
//   }
// }
