import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../util/app_config.dart';
import 'firebase/remote_config_service.dart';
import 'user_repository.dart';

final _apiUrlProd = RemoteConfiguration(key: 'api_url_prod', defaultValue: 'api-rvtjkoqg7q-uc.a.run.app');
final _apiUrlDev = RemoteConfiguration(key: 'api_url_dev', defaultValue: 'api-a4m6ayydzq-uc.a.run.app');

class ApiService {
  final String baseUrl;
  final UserRepository userRepository;

  /// Service for making http calls to the app engine
  ApiService({required this.baseUrl, required this.userRepository});

  static ApiService fromContext(BuildContext context) {
    final config = context.read<AppConfig>();
    final urlConfig = config.isProduction ? _apiUrlProd : _apiUrlDev;

    final remoteConfigService = context.read<RemoteConfigService>();
    final baseUrl = remoteConfigService.get(urlConfig);

    return ApiService(baseUrl: baseUrl, userRepository: context.read<UserRepository>());
  }

  /// Send get request to server and return the parsed body
  /// [path] is the url following the base url, beginning with a slash
  Future<Map<String, dynamic>> get({required String path, Map<String, dynamic>? params}) async {
    if (!userRepository.authenticated) throw AuthException();

    final url = Uri.https(baseUrl, path, params);
    final userIdToken = await _getToken();
    final headers = {'Authorization': 'Bearer $userIdToken'};

    late final Response response;
    try {
      response = await http.get(url, headers: headers);
    } catch (error) {
      if (error is TimeoutException || error is SocketException) {
        throw NoConnectionException();
      } else {
        throw AuthException();
      }
    }
    if (response.statusCode != 200) throw HttpException(response.statusCode);

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post({required String path, Object? body, Map<String, dynamic>? params}) async {
    final url = Uri.https(baseUrl, path, params);

    final userIdToken = await _getToken();
    final headers = {'Authorization': 'Bearer $userIdToken'};

    late final Response response;
    try {
      response = await http.post(url, body: body, headers: headers);
    } catch (error) {
      if (error is TimeoutException || error is SocketException) {
        throw NoConnectionException();
      } else {
        throw AuthException();
      }
    }

    if (response.statusCode != 200) throw HttpException(response.statusCode);

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<String> _getToken() async {
    if (!userRepository.authenticated) throw AuthException();

    try {
      final token = await userRepository.user!.getToken();
      return token;
    } catch (error) {
      if (error is FirebaseAuthException && error.code == 'network-request-failed') {
        throw NoConnectionException();
      } else {
        throw AuthException();
      }
    }
  }
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);
}

class HttpException extends ApiException {
  final int statusCode;

  HttpException(this.statusCode) : super('HTTP status code $statusCode');
}

class AuthException extends ApiException {
  AuthException() : super('Unathenticated');
}

class NoConnectionException extends ApiException {
  NoConnectionException() : super('No connection');
}
