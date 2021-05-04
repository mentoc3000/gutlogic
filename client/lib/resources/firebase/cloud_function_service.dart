import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionService {
  late HttpsCallable _function;

  /// Changes this instance to point to a Cloud Functions emulator running locally.
  ///
  /// @param functionName The name of the Cloud Functions function.
  /// @param origin The origin of the local emulator, such as "//10.0.2.2:5005".
  CloudFunctionService(String functionName, {String? origin}) {
    final instance = FirebaseFunctions.instance;

    if (origin?.isNotEmpty == true) instance.useFunctionsEmulator(origin: origin!);

    // TODO take callable options
    // TODO CloudFunctionService should produce CloudFunctionCallables with a shared origin

    _function = instance.httpsCallable(functionName);
  }

  Future<Map<String, dynamic>> callWith([dynamic parameters]) async {
    final result = await _function.call(parameters);
    return Map<String, dynamic>.from(result.data);
  }
}
