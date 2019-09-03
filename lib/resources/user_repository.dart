import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_cognito_identity_dart/cognito.dart';

// Setup AWS User Pool Id & Client Id settings here:
const _awsUserPoolId = 'us-east-1_cUSIiRhO3'; // "UserPoolId"
const _awsClientId = '7a8qhbu3d5kddqui69l0a42uh6'; // "UserPoolClientId"

const _identityPoolId = 'us-east-1:9297f8fa-ccc1-4349-9625-044008a59137'; // "IdentityPoolId"

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

class UserRepository {
  static CognitoUserPool _userPool =
      new CognitoUserPool(_awsUserPoolId, _awsClientId);
  CognitoUser _cognitoUser;
  CognitoUserSession session;
  CognitoCredentials credentials;

  init() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = new Storage(prefs);
    _userPool.storage = storage;

    _cognitoUser = await _userPool.getCurrentUser();
    session = await _cognitoUser?.getSession();

    credentials = new CognitoCredentials(_identityPoolId, _userPool);
    await credentials.getAwsCredentials(session.getIdToken().getJwtToken());
  }

  Future<bool> authenticate({
    @required String username,
    @required String password,
  }) async {
    // await Future.delayed(Duration(seconds: 1));
    _cognitoUser =
        new CognitoUser(username, _userPool, storage: _userPool.storage);
    final authDetails = new AuthenticationDetails(
      username: username,
      password: password,
    );
    bool isConfirmed;
    try {
      session = await _cognitoUser.authenticateUser(authDetails);
      isConfirmed = true;
    } on CognitoUserNewPasswordRequiredException catch (e) {
      // handle New Password challenge
    } on CognitoUserMfaRequiredException catch (e) {
      // handle SMS_MFA challenge
    } on CognitoUserSelectMfaTypeException catch (e) {
      // handle SELECT_MFA_TYPE challenge
    } on CognitoUserMfaSetupException catch (e) {
      // handle MFA_SETUP challenge
    } on CognitoUserTotpRequiredException catch (e) {
      // handle SOFTWARE_TOKEN_MFA challenge
    } on CognitoUserCustomChallengeException catch (e) {
      // handle CUSTOM_CHALLENGE challenge
    } on CognitoUserConfirmationNecessaryException catch (e) {
      // handle User Confirmation Necessary
      isConfirmed = false;
    } catch (e) {
      print(e);
    }
    // print(session.getAccessToken().getJwtToken());
    // return _session.getAccessToken().getJwtToken();
    if (!session.isValid()) {
      return null;
    }

    return isConfirmed;
  }

  /// Sign up new user
  Future<bool> signUp(
      {@required String email, @required String password}) async {
    CognitoUserPoolData data = await _userPool.signUp(email, password);
    return data.userConfirmed;
  }

  /// Confirm user's account with confirmation code sent to email
  Future<bool> confirmAccount({String email, String confirmationCode}) async {
    _cognitoUser =
        new CognitoUser(email, _userPool, storage: _userPool.storage);

    return await _cognitoUser.confirmRegistration(confirmationCode);
  }

  /// Resend confirmation code to user's email
  Future<void> resendConfirmationCode(String email) async {
    _cognitoUser =
        new CognitoUser(email, _userPool, storage: _userPool.storage);
    await _cognitoUser.resendConfirmationCode();
  }

  /// Check if user's current session is valid
  Future<bool> checkAuthenticated() async {
    if (_cognitoUser == null || session == null) {
      return false;
    }
    return session.isValid();
  }

  Future<bool> hasAccess() async {
    if (_cognitoUser == null || session == null) {
      return false;
    }
    if (!session.isValid()) {
      return false;
    }
    return true;
  }

  String getCurrentUsername() {
    return _cognitoUser?.username;
  }

  Future<void> signOut() async {
    if (credentials != null) {
      await credentials.resetAwsCredentials();
    }
    if (_cognitoUser != null) {
      await _cognitoUser.signOut();
    }
    credentials = null;
    _cognitoUser = null;
    session = null;
  }
}
