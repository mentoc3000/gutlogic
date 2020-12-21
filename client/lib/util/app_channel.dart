import 'package:flutter/services.dart';

/// An AppChannel is a MethodChannel namespaced to the application identifier.
class AppChannel extends MethodChannel {
  const AppChannel(String name) : super('com.gutlogic.app/$name');
}
