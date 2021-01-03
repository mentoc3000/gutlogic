import 'dart:io';

import 'screenshots_util.dart';

/// Wrap Process.run with error throwing for non-zero exit codes.
Future<ProcessResult> run(String command, List<String> arguments) async {
  final result = await Process.run(command, arguments);

  if (result.exitCode == 0) return result;

  throw ProcessException(command, arguments, result.stderr, result.exitCode);
}

/// Build the screenshots driver into a [package] (e.g ios/apk).
Future<void> build(String package, String target) async {
  log.i('Building screenshots driver { package: $package }');

  await run('flutter', [
    'build',
    package,
    if (package == 'ios') '--simulator',
    '--flavor=development',
    '--target=$target',
  ]);

  log.i('Finished building screenshots driver { package: $package }');
}

/// Run the screenshots driver for a given [group] and [deviceID].
Future<void> drive(String target, String driver, String deviceID) async {
  log.i('Running screenshots driver on $deviceID');

  await run('flutter', [
    'drive',
    '--no-build',
    '--flavor=development',
    '--target=$target',
    '--driver=$driver',
    '--device-id=$deviceID',
  ]);

  log.i('Finished screenshots driver on $deviceID');
}
