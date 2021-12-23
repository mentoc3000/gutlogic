import 'dart:io';

import 'package:flutter/services.dart';

class _ExceptionMessages {
  // Connection exceptions
  static String noInternet = 'No internet connection.';
  static String serverConnection = 'Problem communicating with the server.';

  // Firestore exceptions
  static String operationCanceled = 'The operature was canceled.';
  static String invalidArgument = 'Input data is invalid.';
  static String dataNotFound = 'That data was not found.';

  // Default
  static String defaultMessage = 'Uh oh, something went wrong.';
}

String? connectionExceptionMessage(dynamic error) {
  if (error is SocketException) return _ExceptionMessages.noInternet;
  if (error is HttpException) return _ExceptionMessages.serverConnection;
  return null;
}

String? firestoreExceptionString(dynamic error) {
  if (error is PlatformException) {
    switch (error.code) {
      case 'aborted':
      case 'cancelled':
        return _ExceptionMessages.operationCanceled;
      case 'invalid-argument':
        return _ExceptionMessages.invalidArgument;
      case 'not-found':
        return _ExceptionMessages.dataNotFound;
      case 'unavailable':
        return _ExceptionMessages.serverConnection;
    }
  }
  return null;
}

String defaultExceptionString = _ExceptionMessages.defaultMessage;
