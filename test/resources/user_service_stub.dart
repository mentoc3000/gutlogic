import 'dart:async';
import 'package:amazon_cognito_identity_dart/cognito.dart';

const _awsUserPoolId = 'us-east-1_g5I647HDV';
const _awsClientId = '7og2og27lm3tf7mp46759emd9l';

const _identityPoolId = 'us-east-1:0821f23e-a659-4393-8d38-1c40dcefc8b0';

class UserServiceStub {
  static final _email = 'jp.sheehan2@gmail.com';
  static final _password = 'Abra2Cadabra!!';

  UserServiceStub();

  Future<CognitoCredentials> getCredentials() async {
    CognitoUserPool _userPool =
        new CognitoUserPool(_awsUserPoolId, _awsClientId);
    CognitoUser _cognitoUser = new CognitoUser(_email, _userPool);

    final authDetails = new AuthenticationDetails(
      username: _email,
      password: _password,
    );
    CognitoUserSession _session =
        await _cognitoUser.authenticateUser(authDetails);

    CognitoCredentials credentials =
        new CognitoCredentials(_identityPoolId, _userPool);
    await credentials.getAwsCredentials(_session.getIdToken().getJwtToken());

    return credentials;
  }
}
