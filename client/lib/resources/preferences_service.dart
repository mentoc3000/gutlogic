import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../models/preferences/preferences.dart';
import '../models/user/application_user.dart';
import 'firebase/firestore_service.dart';

export 'package:gutlogic/models/user/profile.dart';

class PreferencesService {
  late final UntypedDocumentReference _document;

  final BehaviorSubject<Preferences> stream = BehaviorSubject();

  Preferences get value => stream.valueOrNull ?? Preferences();

  PreferencesService({required FirestoreService firestore, required UserRepository userRepository}) {
    _document = firestore.userPreferences;
    final preferencesStream = _document.snapshots().map(_deserialize);
    CombineLatestStream.combine2(preferencesStream, userRepository.stream, filterPreferences).pipe(stream);
  }

  /// Remove premium preferences if the user does not have an active subscription.
  Preferences filterPreferences(Preferences preferences, ApplicationUser? user) {
    final hasPremium = user?.hasActivePremiumSubscription ?? false;
    return hasPremium ? preferences : preferences.rebuild((b) => b..irritantsExcluded = null);
  }

  static PreferencesService fromContext(BuildContext context) {
    return PreferencesService(
      firestore: context.read<FirestoreService>(),
      userRepository: context.read<UserRepository>(),
    );
  }

  Preferences _deserialize(UntypedDocumentSnapshot snapshot) {
    final preferences = Preferences.deserialize(snapshot.data() ?? {});
    return preferences ?? Preferences();
  }

  Future<void> update(Preferences preferences) {
    final serialized = Preferences.serialize(preferences) ?? {};

    serialized['irritantsExcluded'] ??= FieldValue.delete();

    return _document.set(serialized, SetOptions(merge: true));
  }

  Future<void> updateIrritantFilter(String irritant, bool include) {
    final irritants = value.irritantsExcluded?.toSet() ?? {};
    if (include) {
      irritants.remove(irritant);
    } else {
      irritants.add(irritant);
    }
    return update(value.rebuild((b) => b..irritantsExcluded = irritants.toBuiltSet().toBuilder()));
  }
}
