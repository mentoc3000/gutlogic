import 'package:path/path.dart' as p;

import 'screenshots_config.dart';
import 'screenshots_process.dart';
import 'screenshots_util.dart';

/// Resize Android images
///
/// Flutter only captures the Flutter screen, leaving out the bottom, native
/// navigation bar. This function resizes the image, extending it vertically
/// and adding a black bar to the bottom where the navigation bar would be.
/// This area is cut off in the final screenshots because of how FrameIt
/// positions the frames.
Future<void> resizeAndroidScreenshots(List<AndroidConfig> configs) async {
  await _removeExtraScreenshots();
  final paths = await _paths();

  for (var path in paths) {
    log.i('Processing $path');
    // Resize images
    await _resizeAndroidScreenshot(path);

    // Move images to correct metadata folders
    final width = _width(path);
    final config = configs.firstWhere((element) => element.width == width);
    await _moveScreenshot(path, config.sizes);
  }
}

/// Google Play Store only allows 8 screenshots. Remove extras
Future<void> _removeExtraScreenshots() async {
  final dir = 'android/fastlane/metadata/android/en-US/images/flutterShot';
  await run('find', [dir, '-type', 'f', '-name', '*bowel_movement*', '-delete']);
}

int _width(String path) {
  final filename = p.basename(path);
  final width = filename.split('x').first;
  return int.parse(width);
}

Future<Iterable<String>> _paths() async {
  try {
    final result = await run('find', ['android/fastlane/metadata/android/en-US/images/flutterShot', '-type', 'f']);
    return (result.stdout as String).split('\n').where((element) => element.isNotEmpty);
  } catch (_) {
    return [];
  }
}

Future<void> _resizeAndroidScreenshot(String path) async {
  // Filename contains the device size, to which the Flutter screenshot should be adjusted.
  final filename = p.basename(path);
  final newSize = filename.split(' ').first;
  await run('magick', [path, '-background', 'black', '-extent', newSize, path]);
}

Future<void> _moveScreenshot(String oldPath, List<String> screenSizes) async {
  final imagesDir = p.dirname(p.dirname(oldPath));
  final filename = p.basename(oldPath);

  for (var screenSize in screenSizes) {
    final screenshotDir = p.join(imagesDir, screenSize + 'Screenshots');
    await run('mkdir', ['-p', screenshotDir]);
    final newPath = p.join(screenshotDir, filename);
    await run('cp', [oldPath, newPath]);
  }

  await run('rm', [oldPath]);
}
