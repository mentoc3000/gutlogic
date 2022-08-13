import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../util/app_config.dart';
import 'user_repository.dart';

const _baseUrlDev = 'api-a4m6ayydzq-uc.a.run.app';
const _baseUrlProd = 'api-rvtjkoqg7q-uc.a.run.app';

class ApiService {
  final String baseUrl;
  final UserRepository userRepository;

  /// Service for making http calls to the app engine
  ApiService({required this.baseUrl, required this.userRepository});

  static ApiService fromContext(BuildContext context) {
    final config = context.read<AppConfig>();
    final baseUrl = config.isProduction ? _baseUrlProd : _baseUrlDev;
    return ApiService(baseUrl: baseUrl, userRepository: context.read<UserRepository>());
  }

  /// Send get request to server and return the parsed body
  /// [path] is the url following the base url, beginning with a slash
  Future<Map<String, dynamic>> get({required String path, Map<String, dynamic>? params}) async {
    if (!userRepository.authenticated) throw AuthException();

    final url = Uri.https(baseUrl, path, params);
    final userIdToken = await userRepository.user!.getToken();
    final headers = {'Authorization': 'Bearer $userIdToken'};
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) throw HttpException(response.statusCode);

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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
