import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppSyncService {
  static final _region = 'us-east-1';
  static final _endpoint =
      'https://vaakik5q2fguvg5q2ibwmhblo4.appsync-api.us-east-1.amazonaws.com/graphql'; // "GraphQLApiEndpoint"

  CognitoUserSession session;

  AppSyncService(this.session);

  Future<Map<String, dynamic>> _request(Map<String, dynamic> body) async {
    final response = await http.post(
      _endpoint,
      headers: {
        'Authorization': session.getAccessToken().getJwtToken(),
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> query(
      String operationName, String operation) async {
    final query = 'query $operationName { $operation }';
    final body = {'operationName': operationName, 'query': query};
    return await _request(body);
  }

  static BuiltList<Map<String, dynamic>> getItems(
      Map<String, dynamic> parsedJson, String operationName) {
    // return parsedJson['data'][operationName]['items'];
    return BuiltList<Map<String, dynamic>>(
        (parsedJson['data'][operationName]['items'] as List)
            .cast<Map<String, dynamic>>());
  }
}
