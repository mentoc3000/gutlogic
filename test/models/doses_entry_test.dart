import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/models/dose.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/quantity.dart';

void main() {
  group('DosesEntry', () {
    test('constructs empty object', () {
      DosesEntry dosesEntry = DosesEntry();
      expect(dosesEntry.doses, []);
      expect(dosesEntry.dateTime, null);
    });

    test('constructs simple object', () {
      List<Dose> doses = [Dose()];
      DateTime dateTime = DateTime.now();
      DosesEntry dosesEntry = DosesEntry(
        doses: doses,
        dateTime: dateTime,
      );
      expect(dosesEntry.doses, doses);
      expect(dosesEntry.dateTime, dateTime);
    });

    test('is equatable', () {
      final constructDose = () => DosesEntry(
            doses: [Dose()],
            dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
          );
      expect(constructDose(), constructDose());
    });

    test('is deserializable', () {
      Dose dose = Dose(
        medicine: Medicine(name: 'Pro-9'),
        quantity: Quantity(amount: 3.0, unit: 'Pill'),
      );
      DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(0);
      Map<String, dynamic> dosesJson = {
        'doses': [dose.toJson()],
        'dateTime': dateTime.toIso8601String(),
      };
      DosesEntry dosesEntry = DosesEntry.fromJson(dosesJson);
      expect(dosesEntry.doses, [dose]);
      expect(dosesEntry.dateTime, dateTime);
    });

    test('is serializable', () {
      Dose dose = Dose(
        medicine: Medicine(name: 'Pro-9'),
        quantity: Quantity(amount: 3.0, unit: 'Pill'),
      );
      DosesEntry dosesEntry = DosesEntry(
        doses: [dose],
        dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
      );
      expect(dosesEntry.toJson(), {
        'doses': [dose.toJson()],
        'dateTime': DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String(),
      });
    });
  });
}
