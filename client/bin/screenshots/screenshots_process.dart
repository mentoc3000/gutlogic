import 'dart:io';

import 'screenshots_util.dart';

/// Wrap Process.run with error throwing for non-zero exit codes.
Future<ProcessResult> run(String command, List<String> arguments, {String? workingDirectory}) async {
  final result = await Process.run(command, arguments, workingDirectory: workingDirectory, runInShell: true);

  if (result.exitCode == 0) return result;

  throw ProcessException(command, arguments, result.stderr, result.exitCode);
}

/// Wrap Process.start launching a detached process
Future<Process> runDetached(String command, List<String> arguments, {String? workingDirectory}) {
  return Process.start(
    command,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.detachedWithStdio,
    runInShell: true,
  );
}

/// Build the screenshots driver into a [package] (e.g ios/appbundle).
Future<void> build(String package, String target) async {
  if (package == 'ios') {
    await run('flutter', ['clean']);
    await run('flutter', ['pub', 'get']);

    log.i('Installing pods');
    await run('pod', ['install'], workingDirectory: 'ios');
  }

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

/// Run the screenshots driver for a given [query] and [deviceID].
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
