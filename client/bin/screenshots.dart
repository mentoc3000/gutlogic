import 'dart:io';

import 'package:gutlogic/util/future_ext.dart';

import 'screenshots/screenshots_config.dart';
import 'screenshots/screenshots_emulator_ios.dart' as ios;
import 'screenshots/screenshots_emulator_android.dart' as android;
import 'screenshots/screenshots_postprocessing.dart';
import 'screenshots/screenshots_process.dart';
import 'screenshots/screenshots_util.dart';

const target = 'bin/screenshots_target.dart';
const driver = 'bin/screenshots_driver.dart';

void main(List<String> arguments) async {
  final config = await ScreenshotsConfig.load('bin/screenshots_config.yaml');

  if (arguments.isEmpty || arguments.contains('ios')) {
    try {
      await build('ios', target);
      await orchestrateIOSJobs(config);
    } catch (ex) {
      log.e('Error running screenshots driver on iOS: $ex');
      exit(1);
    }
  }

  if (arguments.isEmpty || arguments.contains('android')) {
    try {
      await build('appbundle', target);
      await orchestrateAndroidJobs(config);
    } catch (ex) {
      log.e('Error running screenshots driver on Android: $ex');
      exit(1);
    }
  }

  log.i('Finished running screenshots driver');
}

Future<void> orchestrateIOSJobs(ScreenshotsConfig config) async {
  await ios.openAppleSimulator();
  await ios.closeAll();

  final devices = await ios.devices();

  // Sequential future for launching a device, running the screenshot driver on it, and closing the device.
  Future<void> job(ios.AppleSimulatorDevice device) async {
    try {
      await ios.launch(device);
      await drive(target, driver, device.udid);
    } catch (ex) {
      log.e('Error running screenshots driver on $device: $ex');
      rethrow;
    } finally {
      await ios.close(device);
    }
  }

  // Map each iOS target name and locale to a screenshot job.
  final jobs = config.ios.map((String target) {
    final matches = devices.where((config) => config.name == target);

    if (matches.isNotEmpty) {
      final device = matches.first;
      log.i('Matched $target with device $device');
      return () => job(device);
    } else {
      log.e('Unable to find a matching device for target $target');
      throw Exception('Unable to find a matching device for target $target');
    }
  });

  // Execute all of the jobs with limited concurrency.
  await FutureExt.pool(jobs, concurrency: 1);
}

Future<void> orchestrateAndroidJobs(ScreenshotsConfig config) async {
  await android.closeAll();

  final devices = await android.devices();

  // Sequential future for launching a device, running the screenshot driver on it, and closing the device.
  Future<void> job(android.AndroidDevice device) async {
    android.AndroidEmulator? emulator = null;
    try {
      await android.launch(device);
      emulator = (await android.emulators()).firstWhere((element) => element.device.avdName == device.avdName);
      await drive(target, driver, emulator.id);
    } catch (ex) {
      log.e('Error running screenshots driver on $device: $ex');
      rethrow;
    } finally {
      if (emulator != null) {
        await android.close(emulator);
      }
    }
  }

  // Map each Android target name and locale to a screenshot job.
  final jobs = config.android.map((AndroidConfig target) {
    final matches = devices.where((device) => device.device == target.device);

    if (matches.isNotEmpty) {
      final device = matches.first;
      log.i('Matched ${target.device} with device $device');
      return () => job(device);
    } else {
      log.e('Unable to find a matching device for target $target');
      throw Exception('Unable to find a matching device for target $target');
    }
  });

  // Execute all of the jobs with limited concurrency.
  await FutureExt.pool(jobs, concurrency: 1);

  await resizeAndroidScreenshots(config.android);
}
