import 'dart:async';
import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:http/http.dart' as http;



class AwsSigV4Service {
  static final _region = 'us-east-1';
  static final _endpoint = 'https://psjb3o5scf.execute-api.us-east-1.amazonaws.com/dev';
  CognitoCredentials credentials;
  AwsSigV4Client awsSigV4Client;

  AwsSigV4Service(this.credentials) {
    awsSigV4Client = AwsSigV4Client(credentials.accessKeyId, 
                                    credentials.secretAccessKey, 
                                    _endpoint,
                                    region: _region, 
                                    sessionToken: credentials.sessionToken);
  }

  Future<http.Response> request (String method, String path) async {
    final methodCaps = method.toUpperCase();
    final signedRequest = new SigV4Request(awsSigV4Client, method: methodCaps, path: path);
    final response = await http.get(signedRequest.url, headers: signedRequest.headers);
    return response;
  }

}