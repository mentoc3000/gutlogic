import 'dart:async';
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_service.dart';

const _awsUserPoolId = 'us-east-1_g5I647HDV';
const _awsClientId = '7og2og27lm3tf7mp46759emd9l';

const _identityPoolId = 'us-east-1:0821f23e-a659-4393-8d38-1c40dcefc8b0';
const _email = 'jp.sheehan2@gmail.com';
const _password = 'Abra2Cadabra!!';

class AppSyncService {
  static final _region = 'us-east-1';
  static final _endpoint =
      'https://j2tiu53n6neijg4ui62usmcrdu.appsync-api.us-east-1.amazonaws.com/graphql';
  static final _apiId = 'coyxq2bw5naqjdpp5jevvroeli';
  CognitoCredentials credentials;
  AwsSigV4Client awsSigV4Client;

  AppSyncService(this.credentials) {
    awsSigV4Client = AwsSigV4Client(
        credentials.accessKeyId, credentials.secretAccessKey, _endpoint,
        serviceName: 'appsync',
        region: _region,
        sessionToken: credentials.sessionToken);
  }

  Future<String> listFoods() async {
    CognitoUserPool _userPool =
        new CognitoUserPool(_awsUserPoolId, _awsClientId);
    CognitoUser _cognitoUser = new CognitoUser(_email, _userPool);

    final authDetails = new AuthenticationDetails(
      username: _email,
      password: _password,
    );
    CognitoUserSession session =
        await _cognitoUser.authenticateUser(authDetails);
    final query = '''query listFoods {
        listFoods {
          items {
            name
          }
        }
      }''';
    final body = {'operationName': 'listFoods', 'query': query};
    // final signedRequest = new SigV4Request(awsSigV4Client,
    //     method: 'POST',
    //     path: _endpoint,
    //     headers: new Map<String, String>.from(
    //         {'Content-Type': 'application/graphql; charset=utf-8'}),
    //     body: new Map<String, String>.from(
    //         {'operationName': 'listFoods', 'query': query}));
    // final response = await http.post(signedRequest.url,
    //     headers: signedRequest.headers, body: signedRequest.body);
    final response = await http.post(
      _endpoint,
      headers: {
        'Authorization': session.getAccessToken().getJwtToken(),
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
    return response.body;
  }
}
