import '../resources/firebase/cloud_function_service.dart';

/// Check with the server to see if our client version is obsolete.
Future<bool> isClientObsolete(CloudFunctionService cloudFunctionService, String version) async {
  Map<String, dynamic> response;

  try {
    response = await cloudFunctionService.function('version').call({version: version});
  } catch (ex) {
    return false; // assume we are compatible if we can't reach the server
  }

  // We are only considered obsolete if we get negative affirmation from the server.
  return response.containsKey('data') && response['data']['supported'] == false;
}
