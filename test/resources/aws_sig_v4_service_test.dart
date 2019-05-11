import 'package:flutter_test/flutter_test.dart';

import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:gut_ai/resources/aws_sig_v4_service.dart';

void main() {
  group('SigV4 service', () {
    const _awsUserPoolId = 'us-east-1_g5I647HDV';
    const _awsClientId = '7og2og27lm3tf7mp46759emd9l';

    const _identityPoolId = 'us-east-1:0821f23e-a659-4393-8d38-1c40dcefc8b0';

    test('should say hello', () async {
      const email = 'jp.sheehan2@gmail.com';
      const password = 'Abra2Cadabra!!';

      CognitoUserPool _userPool =
          new CognitoUserPool(_awsUserPoolId, _awsClientId);
      CognitoUser _cognitoUser = new CognitoUser(email, _userPool);
      
      final authDetails = new AuthenticationDetails(
        username: email,
        password: password,
      );
      CognitoUserSession _session =
          await _cognitoUser.authenticateUser(authDetails);

      CognitoCredentials credentials =
          new CognitoCredentials(_identityPoolId, _userPool);
      await credentials.getAwsCredentials(_session.getIdToken().getJwtToken());

      final sigV4Service = new AwsSigV4Service(credentials);
      final response = await sigV4Service.apiRequest('GET', '/say-hello');
      expect(response.body, '"Greetings Earthling!"');
    });
  });
}
