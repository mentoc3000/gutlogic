import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../auth/auth.dart';
import '../models/application_user.dart';

class UserRepository {
  final FirebaseFirestore _firebaseData;
  final FirebaseAuth _firebaseAuth;
  final Authenticator _authenticator;

  /// The _currentUserStream emits every time the FirebaseUser or its associated metadata document is updated with
  /// distinct values. It will always contain the most recent distinct value of our application user.
  BehaviorSubject<ApplicationUser> _currentUserStream;

  /// True if there is an authenticated user available.
  bool get authenticated => _currentUserStream.value != null;

  /// A stream of distinct users. This emits a new value when the user logs in or out, but also when the user
  /// metadata or auth providers are changed. If there is no authenticated user, the stream value will be null.
  BehaviorSubject<ApplicationUser> get stream => _currentUserStream;

  /// The current user, or null.
  ApplicationUser get user => _currentUserStream.value;

  UserRepository({FirebaseFirestore firebaseData, FirebaseAuth firebaseAuth, Authenticator authenticator})
      : _firebaseData = firebaseData ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _authenticator = authenticator ?? Authenticator() {
    _currentUserStream = _createApplicationUserStream(_firebaseAuth.userChanges());
  }

  /// Transform a stream of FirebaseUsers into a stream of ApplicationUsers.
  BehaviorSubject<ApplicationUser> _createApplicationUserStream(Stream<User> users) {
    bool isFirebaseUIDDistinct(User prev, User next) {
      return prev?.uid == next?.uid;
    }

    Stream<DocumentSnapshot> mapUserToSnapshotStream(User user) {
      return user == null ? Stream.value(null) : _getUserMetaDocumentReference(user.uid).snapshots();
    }

    // Transform the stream of users into a stream of snapshots. The user stream emits new values for a few different
    // operations but we only want a new snapshot stream when the UID changes, so we filter for distinct UIDs.
    final snapshots = users.distinct(isFirebaseUIDDistinct).switchMap(mapUserToSnapshotStream);

    // Combine the stream of users (not distinct UIDs this time) and the stream of snapshots into an async map, which
    // creates a new ApplicationUser each time either value changes. We end up with a stream of ApplicationUsers that
    // emits whenever the Firebase User or metadata document is meaningfully changed.
    final applicationUserStream = CombineLatestStream.list([users, snapshots]).asyncMap((values) async {
      final user = values[0] as User;
      final snap = values[1] as DocumentSnapshot;

      if (user == null || snap == null) return null;

      final data = snap.data() ?? {};

      data['id'] = user.uid;
      data['email'] = user.email;
      data['providers'] = user.providerData.map((data) => data.providerId);
      data['verified'] = user.emailVerified;

      return ApplicationUser.fromJSON(data);
    });

    // Filter out identical application users. This can happen when the FirebaseUser stream emits a new user with the
    // same values, like when the auth state changes or the password is updated.
    final distinctApplicationUserStream = applicationUserStream.distinct();

    // Pipe the user stream into an rxdart BehaviorSubject, which has better stream features.
    final applicationUserSubject = BehaviorSubject<ApplicationUser>.seeded(null);
    applicationUserSubject.addStream(distinctApplicationUserStream);
    return applicationUserSubject;
  }

  /// Create a future that waits for the first user that passes the filter lambda.
  Future<void> _firstUserWhere(bool Function(ApplicationUser) where) {
    return _currentUserStream.firstWhere(where);
  }

  /// Get the Firebase DocumentReference with the user metadata.
  DocumentReference _getUserMetaDocumentReference(String uid) {
    return _firebaseData.collection('users').doc(uid);
  }

  /// Throws a [StateError] if authenticated.
  void _requireUnauthenticatedState() {
    if (authenticated) throw StateError('This operation requires the repository to not be authenticated.');
  }

  /// Throws a [StateError] if not authenticated.
  void _requireAuthenticatedState() {
    if (authenticated == false) throw StateError('This operation requires the repository to be authenticated.');
  }

  /// Login with a [credential].
  ///
  /// Throws a [StateError] if already authenticated. Throws a [DuplicateUsernameException] if a federated [credential]
  /// has an email already in use by different account. Throws an [InvalidCredentialException] if the [credential] is
  /// malformed or invalid. Throws an [InvalidOperationException] if the [credential] provider is disabled. Throws a
  /// [DisabledUserException] if the [credential] is for a disabled account. Throws a [MissingUserException] if the
  /// [credential] is for an account that does not exist. Throws a [WrongPasswordException] if the [credential] has the
  /// wrong password for the account.
  Future<void> login({@required AuthCredential credential}) async {
    _requireUnauthenticatedState();

    UserCredential result;

    try {
      result = await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    if (result.user == null) {
      throw MissingUserException();
    }

    await _firstUserWhere((user) => user != null);
  }

  /// Create a new account with a [username] and [password], and then login with a password credential.
  ///
  /// New accounts with federated providers are handled by simply logging in with the federated auth credential.
  ///
  /// Throws a [StateError] if already authenticated. Throws a [DuplicateUsernameException] if the [username] is already
  /// in use. Throws an [InvalidUsernameException] if the [username] is invalid. Throws an [InvalidPasswordException] if
  /// the [password] is invalid or weak. Throws an [InvalidOperationException] if the [password] auth provider is
  /// disabled.
  Future<void> register({@required String username, @required String password}) async {
    _requireUnauthenticatedState();

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: username, password: password);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    final authentication = await _authenticator.authenticate(
      provider: AuthProvider.password,
      username: username,
      password: password,
    );

    await login(credential: authentication.credential);
  }

  /// Send an email verification to the current user.
  ///
  /// Throws a [StateError] if not authenticated.
  Future<void> sendEmailVerification() async {
    _requireAuthenticatedState();

    try {
      await _firebaseAuth.currentUser.sendEmailVerification();
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }
  }

  /// Refresh the email verification of the current user. Returns true if the user has verified their email.
  ///
  /// Throws a [StateError] if not authenticated.
  Future<bool> refreshEmailVerification() async {
    _requireAuthenticatedState();

    final isEmailVerified = _firebaseAuth.currentUser.emailVerified;

    // Skip reloading the user if we already have a verified user.
    if (isEmailVerified) return true;

    try {
      await _firebaseAuth.currentUser.reload();
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    // Wait for the user stream to update with the user change if we reloaded a verified user.
    if (_firebaseAuth.currentUser.emailVerified) {
      await _firstUserWhere((user) => user.verified);
    }

    return user.verified;
  }

  /// Update the [username] associated with the current user.
  ///
  /// This is only valid if the user is linked to a password auth provider, and requires a recent reauthentication.
  ///
  /// Throws a [StateError] if not authenticated. Throws a [MissingProviderException] if the user is not linked to a
  /// password provider. Throws an [InvalidUsernameException] if the [username] is not a valid email. Throws a
  /// [DuplicateUsernameException] if the username is already used. Throws a [StaleAuthenticationException] if the user
  /// has not recently authenticated.
  Future<void> updateUsername({@required String username}) async {
    _requireAuthenticatedState();

    if (user.providers.contains(AuthProvider.password) == false) throw MissingProviderException();

    try {
      await _firebaseAuth.currentUser.updateEmail(username);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    await _firstUserWhere((user) => user.username == username);
  }

  /// Update the [currentPassword] for the current user to [updatedPassword].
  ///
  /// This is only valid if the user is linked to a password auth provider, and requires a recent reauthentication.
  ///
  /// Throws a [StateError] if not authenticated. Throws a [MissingProviderException] if the user is not linked to a
  /// password provider. Throws an [InvalidPasswordException] if the [updatedPassword] is an invalid or weak
  /// password. Throws a [StaleAuthenticationException] if the user has not recently authenticated.
  Future<void> updatePassword({@required String currentPassword, @required String updatedPassword}) async {
    _requireAuthenticatedState();

    if (user.providers.contains(AuthProvider.password) == false) throw MissingProviderException();

    try {
      await _firebaseAuth.currentUser.updatePassword(updatedPassword);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    // Updating the password does not emit a new user.
  }

  /// Update the user metadata with the values found in [updatedUser].
  ///
  /// This cannot be used to update the user ID, email, or auth providers.
  ///
  /// Throws a [StateError] if not authenticated.
  Future<void> updateMetadata({@required ApplicationUser updatedUser}) async {
    _requireAuthenticatedState();

    if (user == updatedUser) return;

    final json = updatedUser.toJSON();

    // These properties need to be changed through other methods.
    assert(user.id == updatedUser.id);
    assert(user.email == updatedUser.email);
    assert(user.providers == updatedUser.providers);

    // Manually strip the document JSON of properties we don't want to saved to the user document.
    json.remove('id');
    json.remove('email');
    json.remove('providers');

    await _getUserMetaDocumentReference(user.id).set(json);

    await _firstUserWhere((user) => user == updatedUser);
  }

  /// Get the set of auth providers linked to an account [username].
  Future<Set<AuthProvider>> getAvailableAuthProviders({@required String username}) async {
    List<String> methods;

    try {
      methods = await _firebaseAuth.fetchSignInMethodsForEmail(username);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    return methods.map(fromFirebaseProviderID).toSet();
  }

  /// Reauthenticate a user with a fresh credential. Call this before modifying sensitive user data, like updating
  /// the password or linking a new account.
  ///
  /// Throws a [StateError] if not authenticated. Throws a [MismatchedUserException] if the [credential] is for a
  /// different user. Throws a [MissingUserException] if the [credential] does not correspond to any user. Throws an
  /// [InvalidCredentialException] if the [credential] is malformed or invalid. Throws an [InvalidUsernameException] if
  /// the [credential] has an invalid username. Throws an [InvalidPasswordException] if the [credential] has an
  /// invalid password. Throws a [WrongPasswordException] if the [credential] has the wrong password for the account.
  Future<void> reauthenticate({@required AuthCredential credential}) async {
    _requireAuthenticatedState();

    try {
      await _firebaseAuth.currentUser.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }
  }

  /// Returns true if the [username] is linked with a certain auth [provider].
  Future<bool> isAuthProviderLinked({@required String username, @required AuthProvider provider}) async {
    final providers = await getAvailableAuthProviders(username: username);
    return providers.contains(provider);
  }

  /// Link the current user with a new auth [provider] using the [credential]. This requires a recent reauthentication.
  ///
  /// Throws a [StateError] if not authenticated. Throws a [DuplicateProviderException] if the user is already linked to
  /// the auth [provider].
  Future<void> linkAuthProvider({@required AuthProvider provider, @required AuthCredential credential}) async {
    _requireAuthenticatedState();

    if (user.providers.contains(provider)) throw DuplicateProviderException();

    try {
      await _firebaseAuth.currentUser.linkWithCredential(credential);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    await _firstUserWhere((user) => user.providers.contains(provider));
  }

  /// Unlink the current user from the auth [provider]. This requires a recent reauthentication.
  ///
  /// Throws a [StateError] if not authenticated. Throws a [MissingProviderException] if the user is not linked to the
  /// auth [provider].
  Future<void> unlinkAuthProvider({@required AuthProvider provider}) async {
    _requireAuthenticatedState();

    if (user.providers.contains(provider) == false) throw MissingProviderException();

    try {
      await _firebaseAuth.currentUser.unlink(toFirebaseProviderID(provider));
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    await _firstUserWhere((user) => user.providers.contains(provider) == false);
  }

  /// Send a password reset email to [email].
  ///
  /// Throws a [StateError] if not authenticated. Throws an [MissingUserException] if the email is not registered with
  /// an account. Throws an [InvalidUsernameException] if the email is invalid.
  Future<void> resetPassword({String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }
  }

  /// Delete the current user account. This requires a recent reauthentication.
  ///
  /// Deleting a user automatically deletes their user data and metadata via a background server job.
  ///
  /// Throws a [StateError] if not authenticated. Throws [StaleAuthenticationException] if the user has not recently
  /// authenticated.
  Future<void> delete() async {
    _requireAuthenticatedState();

    try {
      await _firebaseAuth.currentUser.delete();
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    await _authenticator.deauthenticate();

    await _firstUserWhere((user) => user == null);
  }

  /// Log out and deauthenticate the current user.
  Future<void> logout() async {
    if (authenticated == false) return;

    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (ex) {
      throw ex.toAuthException();
    }

    await _authenticator.deauthenticate();

    await _firstUserWhere((user) => user == null);
  }
}
