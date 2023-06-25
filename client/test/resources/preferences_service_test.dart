import 'package:built_collection/built_collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/preferences/preferences.dart';
import 'package:gutlogic/models/user/application_user.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/preferences_service.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'preferences_service_test.mocks.dart';

@GenerateMocks([UserRepository, ApplicationUser])
void main() {
  group('PreferencesService', () {
    const path = 'user_preferences/testUID';
    late MockUserRepository userRepository;
    late PreferencesService service;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      final user = MockApplicationUser();
      when(user.hasActivePremiumSubscription).thenReturn(true);
      userRepository = MockUserRepository();
      when(userRepository.stream).thenAnswer((_) => BehaviorSubject<ApplicationUser>()..add(user));
      service = PreferencesService(
        firestore: FirestoreService(userID: 'testUID', instance: firestore),
        userRepository: userRepository,
      );
    });

    test('streams preferences', () async {
      await firestore.doc(path).set({
        'irritantsExcluded': ['Lactose']
      });
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(service.stream.value, Preferences(irritantsExcluded: BuiltSet({'Lactose'})));

      await firestore.doc(path).set({});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(service.stream.value, Preferences());
    });

    test('updates preferences', () async {
      await service.update(Preferences(irritantsExcluded: BuiltSet({'Lactose'})));
      expect((await firestore.doc(path).get()).data(), {
        'irritantsExcluded': ['Lactose']
      });

      await service.update(Preferences(irritantsExcluded: BuiltSet({'Lactose', 'Mannitol'})));
      expect((await firestore.doc(path).get()).data(), {
        'irritantsExcluded': ['Lactose', 'Mannitol'],
      });

      await service.update(Preferences());
      expect((await firestore.doc(path).get()).data(), <String, dynamic>{});
    });

    test('hides premium preferences', () async {
      final user = MockApplicationUser();
      when(user.hasActivePremiumSubscription).thenReturn(false);
      userRepository = MockUserRepository();
      when(userRepository.stream).thenAnswer((_) => BehaviorSubject<ApplicationUser>()..add(user));
      service = PreferencesService(
        firestore: FirestoreService(userID: 'testUID', instance: firestore),
        userRepository: userRepository,
      );

      await firestore.doc(path).set({
        'irritantsExcluded': ['Lactose']
      });
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(service.stream.value, Preferences());
    });
  });
}
