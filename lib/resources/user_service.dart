import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:http/http.dart' as http;

// Setup AWS User Pool Id & Client Id settings here:
const _awsUserPoolId = 'us-east-1_g5I647HDV';
const _awsClientId = '7og2og27lm3tf7mp46759emd9l';

const _identityPoolId = 'us-east-1:0821f23e-a659-4393-8d38-1c40dcefc8b0';

/// Extend CognitoStorage with Shared Preferences to persist account
/// login sessions
class Storage extends CognitoStorage {
  SharedPreferences _prefs;
  Storage(this._prefs);

  @override
  Future getItem(String key) async {
    String item;
    try {
      item = json.decode(_prefs.getString(key));
    } catch (e) {
      return null;
    }
    return item;
  }

  @override
  Future setItem(String key, value) async {
    _prefs.setString(key, json.encode(value));
    return getItem(key);
  }

  @override
  Future removeItem(String key) async {
    final item = getItem(key);
    if (item != null) {
      _prefs.remove(key);
      return item;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    _prefs.clear();
  }
}

class Counter {
  int count;
  Counter(this.count);

  factory Counter.fromJson(json) {
    return new Counter(json['count']);
  }
}

class User {
  String email;
  String name;
  String password;
  bool confirmed = false;
  bool hasAccess = false;

  User({this.email, this.name});

  /// Decode user from Cognito User Attributes
  factory User.fromUserAttributes(List<CognitoUserAttribute> attributes) {
    final user = User();
    attributes.forEach((attribute) {
      if (attribute.getName() == 'email') {
        user.email = attribute.getValue();
      } else if (attribute.getName() == 'name') {
        user.name = attribute.getValue();
      }
    });
    return user;
  }
}

class UserService {
  static final UserService _singleton = new UserService._internal();

  static CognitoUserPool _userPool = new CognitoUserPool(_awsUserPoolId, _awsClientId);
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  // UserService(this._userPool);
  CognitoCredentials credentials;
  bool isInitialized = false;

  factory UserService() {
    return _singleton;
  }

  UserService._internal();

  /// Initiate user session from local storage if present
  Future<bool> init() async {
    if (isInitialized) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    final storage = new Storage(prefs);
    _userPool.storage = storage;

    _cognitoUser = await _userPool.getCurrentUser();
    if (_cognitoUser == null) {
      return false;
    }
    _session = await _cognitoUser.getSession();
    bool sessionIsValid =_session.isValid();
    if (sessionIsValid) {
      isInitialized = true;
    }
    return sessionIsValid;
  }

  /// Get existing user from session with his/her attributes
  Future<User> getCurrentUser() async {
    await init();
    if (_cognitoUser == null || _session == null) {
      return null;
    }
    if (!_session.isValid()) {
      return null;
    }
    final attributes = await _cognitoUser.getUserAttributes();
    if (attributes == null) {
      return null;
    }
    final user = new User.fromUserAttributes(attributes);
    user.hasAccess = true;
    return user;
  }

  /// Retrieve user credentials -- for use with other AWS services
  Future<CognitoCredentials> getCredentials() async {
    await init();
    if (_cognitoUser == null || _session == null) {
      return null;
    }
    credentials = new CognitoCredentials(_identityPoolId, _userPool);
    await credentials.getAwsCredentials(_session.getIdToken().getJwtToken());
    return credentials;
  }

  /// Login user
  Future<User> login(String email, String password) async {
    await init();
    _cognitoUser =
        new CognitoUser(email, _userPool, storage: _userPool.storage);

    final authDetails = new AuthenticationDetails(
      username: email,
      password: password,
    );

    bool isConfirmed;
    try {
      _session = await _cognitoUser.authenticateUser(authDetails);
      isConfirmed = true;
    } on CognitoClientException catch (e) {
      if (e.code == 'UserNotConfirmedException') {
        isConfirmed = false;
      } else {
        throw e;
      }
    }

    if (!_session.isValid()) {
      return null;
    }

    final attributes = await _cognitoUser.getUserAttributes();
    final user = new User.fromUserAttributes(attributes);
    user.confirmed = isConfirmed;
    user.hasAccess = true;

    return user;
  }

  /// Confirm user's account with confirmation code sent to email
  Future<bool> confirmAccount(String email, String confirmationCode) async {
    await init();
    _cognitoUser =
        new CognitoUser(email, _userPool, storage: _userPool.storage);

    return await _cognitoUser.confirmRegistration(confirmationCode);
  }

  /// Resend confirmation code to user's email
  Future<void> resendConfirmationCode(String email) async {
    await init();
    _cognitoUser =
        new CognitoUser(email, _userPool, storage: _userPool.storage);
    await _cognitoUser.resendConfirmationCode();
  }

  /// Check if user's current session is valid
  Future<bool> checkAuthenticated() async {
    await init();
    if (_cognitoUser == null || _session == null) {
      return false;
    }
    return _session.isValid();
  }

  /// Sign up new user
  Future<User> signUp(String email, String password, String name) async {
    await init();
    CognitoUserPoolData data;
    final userAttributes = [
      new AttributeArg(name: 'name', value: name),
    ];
    data =
        await _userPool.signUp(email, password, userAttributes: userAttributes);

    final user = new User();
    user.email = email;
    user.name = name;
    user.confirmed = data.userConfirmed;

    return user;
  }

  Future<void> signOut() async {
    await init();
    if (credentials != null) {
      await credentials.resetAwsCredentials();
    }
    if (_cognitoUser != null) {
      await _cognitoUser.signOut();
    }
    isInitialized = false;
    credentials = null;
    _cognitoUser = null;
    _session = null;
  }
}
