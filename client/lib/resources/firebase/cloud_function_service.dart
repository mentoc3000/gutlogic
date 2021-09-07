import 'package:cloud_functions/cloud_functions.dart';

import './untyped_data.dart';

export './untyped_data.dart';

class CloudFunctionService {
  final FirebaseFunctions _functions;

  /// Create a new cloud function service. Uses the default [FirebaseFunctions] instance if none is provided.
  CloudFunctionService({FirebaseFunctions? functions}) : _functions = functions ?? FirebaseFunctions.instance;

  /// Create a new cloud function callable with the specified [endpoint] and [timeout].
  CloudFunction function(String endpoint) {
    return CloudFunction(callable: _functions.httpsCallable(endpoint));
  }
}

class CloudFunction {
  final HttpsCallable _callable;

  CloudFunction({required HttpsCallable callable}) : _callable = callable;

  Future<UntypedData> call(UntypedData? data) async {
    return (await _callable<UntypedData>(data)).data;
  }
}
