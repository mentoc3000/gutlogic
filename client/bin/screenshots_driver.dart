import 'package:flutter_driver/flutter_driver.dart';

import 'screenshots/screenshots_driver.dart';

void main() {
  screenshots((FlutterDriver driver, CaptureDelegate capture) async {
    await driver.waitFor(find.text('Timeline'));

    await capture('timeline');

    await driver.tap(find.text('Oatmeal'));

    await capture('meal');

    await driver.tap(find.pageBack());
    await driver.tap(find.text('Bowel Movement'));

    await capture('bowel_movement');

    await driver.tap(find.pageBack());
    await driver.tap(find.text('Bloated'));

    await capture('symptom');
  });
}
