import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionService {
  HttpsCallable _function;

  /// Changes this instance to point to a Cloud Functions emulator running locally.
  ///
  /// @param functionName The name of the Cloud Functions function.
  /// @param origin The origin of the local emulator, such as "//10.0.2.2:5005".
  CloudFunctionService(String functionName, {String origin}) {
    final instance =
        origin == null ? CloudFunctions.instance : CloudFunctions.instance.useFunctionsEmulator(origin: origin);
    _function = instance.getHttpsCallable(functionName: functionName);
  }

  Future<Map<String, dynamic>> callWith([dynamic parameters]) async {
    final result = await _function.call(parameters);
    return Map<String, dynamic>.from(result.data);
  }
}
