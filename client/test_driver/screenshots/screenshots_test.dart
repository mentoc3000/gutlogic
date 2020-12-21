import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:screenshots/screenshots.dart';

import '../isolates_workaround.dart';

void main() {
  final config = Config();

  group('Screenshots', () {
    FlutterDriver driver;
    IsolatesWorkaround workaround;

    // finders
    // NOTE: find.byValueKey is not working for Flutter driver due to a known issue
    // https://github.com/flutter/flutter/issues/36244
    // final accountTab = find.byValueKey(Keys.accountTab);
    // final diaryTab = find.byValueKey(Keys.diaryTab);
    // final diaryTitle = find.byValueKey(Keys.diaryTitle);

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      workaround = IsolatesWorkaround(driver);
      await workaround.resumeIsolates();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
        await workaround.tearDown();
      }
    });

    test('check flutter driver health', () async {
      final health = await driver.checkHealth();
      expect(health.status, HealthStatus.ok);
    });

    test('takes screenshots', () async {
      await driver.waitFor(find.text('Timeline'));
      await screenshot(driver, config, 'timeline');
      await driver.tap(find.text('Oatmeal'));
      await screenshot(driver, config, 'meal');
      await driver.tap(find.pageBack());
      await driver.tap(find.text('Bowel Movement'));
      await screenshot(driver, config, 'bowel_movement');
      await driver.tap(find.pageBack());
      await driver.tap(find.text('Bloated'));
      await screenshot(driver, config, 'symptom');
    });
  });
}
