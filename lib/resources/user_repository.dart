import 'dart:async';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_cognito_identity_dart/cognito.dart';

// Setup AWS User Pool Id & Client Id settings here:
const _awsUserPoolId = 'us-east-1_g5I647HDV';
const _awsClientId = '7og2og27lm3tf7mp46759emd9l';

const _identityPoolId = 'us-east-1:0821f23e-a659-4393-8d38-1c40dcefc8b0';

class UserRepository {
  static CognitoUserPool _userPool =
      new CognitoUserPool(_awsUserPoolId, _awsClientId);

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    // await Future.delayed(Duration(seconds: 1));
    CognitoUser cognitoUser = new CognitoUser(username, _userPool);
    final authDetails = new AuthenticationDetails(
      username: username,
      password: password,
    );
    CognitoUserSession session;
    try {
      session = await cognitoUser.authenticateUser(authDetails);
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
    } catch (e) {
      print(e);
    }
    // print(session.getAccessToken().getJwtToken());
    return session.getAccessToken().getJwtToken();
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return false;
  }
}
