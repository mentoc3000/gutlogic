import 'package:flutter_driver/flutter_driver.dart';

import 'data.dart';
import 'screenshots/screenshots_driver.dart';

void main() {
  screenshots((FlutterDriver driver, CaptureDelegate capture) async {
    await driver.waitFor(find.text('Timeline'));

    // Start filename with a number to put them in the correct order on the App Store
    await capture('2. timeline');

    await driver.tap(find.text(mealEntry2.mealElements[0].foodReference.name));

    await capture('3. meal');

    await driver.tap(find.pageBack());
    await driver.tap(find.text('Bowel Movement'));

    await capture('5. bowel_movement');

    await driver.tap(find.pageBack());
    await driver.tap(find.text(symptomEntry.symptom.symptomType.name));

    await capture('4. symptom');

    await driver.tap(find.pageBack());
    await driver.tap(find.text('Pantry'));

    await capture('0. pantry');

    await driver.tap(find.text(food.name));
    await driver.tap(find.text('Details'));

    await capture('1. sensitivity');
  });
}
