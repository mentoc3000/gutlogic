import 'dart:async';
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:http/http.dart' as http;
import 'user_service.dart';
import 'dart:convert';

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
        region: _region, sessionToken: credentials.sessionToken);
  }

  Future<http.Response> apiRequest(
      String method, String path, Map<String, String> body) async {
    final methodCaps = method.toUpperCase();
    final signedRequest =
        new SigV4Request(awsSigV4Client, method: methodCaps, path: path);
    final response = await http.post(signedRequest.url,
        headers: signedRequest.headers, body: json.encode(body));
    return response;
  }

  Future<String> getQuery() async {
    final body = {
      'operationName': 'CreateItem',
      'query': '''mutation CreateItem {
        createItem(name: "Some Name") {
          name
        }
      }''',
    };
    final response = await apiRequest('POST', _endpoint, body);
    return response.body;
  }
}
