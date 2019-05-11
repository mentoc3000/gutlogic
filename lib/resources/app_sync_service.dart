import 'dart:async';
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppSyncService {
  static final _region = 'us-east-1';
  static final _endpoint =
      'https://j2tiu53n6neijg4ui62usmcrdu.appsync-api.us-east-1.amazonaws.com/graphql';
  static final _apiId = 'coyxq2bw5naqjdpp5jevvroeli';
  CognitoUserSession session;

  AppSyncService(this.session) {}

  Future<String> listFoods() async {
    final query = '''query listFoods {
        listFoods {
          items {
            name
          }
        }
      }''';
    final body = {'operationName': 'listFoods', 'query': query};
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
