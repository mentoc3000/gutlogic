import 'dart:async';

import 'package:logger/logger.dart';

Future<void> main(FutureOr<void> Function() testMain) async {
  Logger.level = Level.nothing;
  await testMain();
}
