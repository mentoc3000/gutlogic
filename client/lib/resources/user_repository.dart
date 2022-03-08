import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/auth.dart';
import '../models/application_user.dart';
import 'firebase/firestore_service.dart';

class UserRepository {
  final FirebaseFirestore _firebaseData;
  final FirebaseAuth _firebaseAuth;

  /// The _currentUserStream emits every time the FirebaseUser or its associated metadata document is updated with
  /// distinct values. It will always contain the most recent distinct value of our application user.
  late final BehaviorSubject<ApplicationUser?> _currentUserStream;

  /// True if there is an authenticated user available.
  bool get authenticated => _currentUserStream.value != null;

  /// A stream of distinct users. This emits a new value when the user logs in or out, but also when the user
  /// metadata or auth providers are changed. If there is no authenticated user, the stream value will be null.
  BehaviorSubject<ApplicationUser?> get stream => _currentUserStream;

  /// The current user, or null.
  ApplicationUser? get user => _currentUserStream.value;

  UserRepository({FirebaseFirestore? firebaseData, FirebaseAuth? firebaseAuth})
      : _firebaseData = firebaseData ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _currentUserStream = _createApplicationUserStream(_firebaseAuth.userChanges());
  }

  /// Transform a stream of FirebaseUsers into a stream of ApplicationUsers.
  BehaviorSubject<ApplicationUser?> _createApplicationUserStream(Stream<User?> users) {
    bool isFirebaseUIDDistinct(User? prev, User? next) {
      return prev?.uid == next?.uid;
    }

    Stream<UntypedDocumentSnapshot?> mapUserToSnapshotStream(User? user) {
      return user == null ? Stream.value(null) : _getUserMetaDocumentReference(user.uid).snapshots();
    }

    // Transform the stream of users into a stream of snapshots. The user stream emits new values for a few different
    // operations but we only want a new snapshot stream when the UID changes, so we filter for distinct UIDs.
    final snapshots = users.distinct(isFirebaseUIDDistinct).switchMap(mapUserToSnapshotStream);

    // Combine the stream of users (not distinct UIDs this time) and the stream of snapshots into an async map, which
    // creates a new ApplicationUser each time either value changes. We end up with a stream of ApplicationUsers that
    // emits whenever the Firebase User or metadata document is meaningfully changed.
    final applicationUserStream = CombineLatestStream.list([users, snapshots]).asyncMap((values) async {
      if (values[0] == null || values[1] == null) return null;

      final user = values[0] as User;
      final snap = values[1] as UntypedDocumentSnapshot;
      final data = snap.data() ?? {};

      return ApplicationUser(
        id: user.uid,
        email: user.email,
        verified: user.emailVerified,
        consented: data['consented'] ?? false,
        anonymous: user.isAnonymous,
        providers: BuiltList.from(user.providerData.map((p) => AuthProviderUtil.fromFirebaseProviderID(p.providerId))),
      );
    });

    // Filter out identical application users. This can happen when the FirebaseUser stream emits a new user with the
    // same values, like when the auth state changes or the password is updated.
    final distinctApplicationUserStream = applicationUserStream.distinct();

    // Pipe the user stream into an rxdart BehaviorSubject, which has better stream features.
    final applicationUserSubject = BehaviorSubject<ApplicationUser?>.seeded(null);
    applicationUserSubject.addStream(distinctApplicationUserStream);
    return applicationUserSubject;
  }

  /// Create a future that waits for the first user that passes the filter lambda.
  Future<void> _firstUserWhere(bool Function(ApplicationUser?) where) {
    return _currentUserStream.firstWhere(where);
  }

  /// Get the Firebase DocumentReference with the user metadata.
  DocumentReference<UntypedData> _getUserMetaDocumentReference(String uid) {
    return _firebaseData.collection('users').doc(uid);
  }

  /// Returns true if an account exists for the provided [email].
  Future<bool> exists({required String email}) async {
    try {
      return (await _firebaseAuth.fetchSignInMethodsForEmail(email)).isNotEmpty;
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }
  }

  /// Login with a [credential]. If the email doesn't have an account already, a new account will be created. If the
  /// [credential] is null, an anonymous user will be created.
  Future<void> login({Authentication? authentication}) async {
    if (authenticated) throw RequiresUnauthenticatedError();

    late final UserCredential result;

    try {
      result = await (authentication == null
          ? _firebaseAuth.signInAnonymously()
          : _firebaseAuth.signInWithCredential(authentication.credential));
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }

    if (result.user == null) {
      throw MissingUserException();
    }

    await _firstUserWhere((user) => user != null);
  }

  /// Mark the [user] as having consented to the privacy policy.
  Future<void> consent(ApplicationUser user) async {
    await _getUserMetaDocumentReference(user.id).set({'consented': true}, SetOptions(merge: true));
  }

  /// Reauthenticate a user with a fresh credential.
  Future<void> reauthenticate({required Authentication authentication}) async {
    if (authenticated == false) throw RequiresAuthenticatedError();

    try {
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(authentication.credential);
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }
  }

  /// Link the current user with a new [authentication] provider.
  Future<void> linkAuthProvider({required Authentication authentication}) async {
    if (authenticated == false) throw RequiresAuthenticatedError();

    try {
      await _firebaseAuth.currentUser!.linkWithCredential(authentication.credential);
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }

    await _firstUserWhere((user) => user?.providers.contains(authentication.provider) == true);
  }

  /// Unlink the current user from the auth [provider]. This requires a recent reauthentication.
  Future<void> unlinkAuthProvider({required AuthProvider provider}) async {
    if (authenticated == false) throw RequiresAuthenticatedError();

    try {
      await _firebaseAuth.currentUser!.unlink(AuthProviderUtil.toFirebaseProviderID(provider));
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }

    await _firstUserWhere((user) => user?.providers.contains(provider) == false);
  }

  /// Delete the current user account. This requires a recent reauthentication.
  ///
  /// Deleting a user automatically deletes their user data and metadata via a background server job.
  Future<void> delete() async {
    if (authenticated == false) throw RequiresAuthenticatedError();

    try {
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }

    await _firstUserWhere((user) => user == null);
  }

  /// Log out the current user.
  Future<void> logout() async {
    if (authenticated == false) return;

    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (ex) {
      throw AuthException.from(ex);
    }

    await _firstUserWhere((user) => user == null);
  }
}

class RequiresAuthenticatedError extends StateError {
  RequiresAuthenticatedError() : super('This operation requires the repository to be authenticated.');
}

class RequiresUnauthenticatedError extends StateError {
  RequiresUnauthenticatedError() : super('This operation requires the repository to be unauthenticated.');
}
