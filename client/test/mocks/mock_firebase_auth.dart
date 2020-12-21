import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final _stateChangedStreamController = StreamController<User>();

  User _currentUser;

  MockFirebaseAuth();

  @override
  User get currentUser => _currentUser;

  @override
  Stream<User> userChanges() => _stateChangedStreamController.stream.asBroadcastStream();

  MockUser Function() createMockFirebaseUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({String email, String password}) async {
    return _mockSignIn(createMockFirebaseUser());
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) async {
    return _mockSignIn(createMockFirebaseUser());
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return _mockSignIn(createMockFirebaseUser());
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({String email, String password}) async {
    return MockUserCredential(user: createMockFirebaseUser());
  }

  void _updateCurrentUser(User user) {
    _currentUser = user;
    _stateChangedStreamController.add(user);
  }

  Future<MockUserCredential> _mockSignIn(User user) {
    final result = MockUserCredential(user: user);
    _updateCurrentUser(result.user);
    return Future.value(result);
  }

  @override
  Future<void> signOut() async {
    _updateCurrentUser(null);
  }
}

class MockUser extends Mock implements User {
  final MockFirebaseAuth auth;

  MockUser({
    @required this.auth,
  });

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential cred) async {
    return MockUserCredential(user: this);
  }

  @override
  Future<void> updateEmail(String email) async {
    when(this.email).thenReturn(email);
    auth._updateCurrentUser(this);
  }

  @override
  Future<void> updatePassword(String password) async {
    auth._updateCurrentUser(this);
  }
}

class MockUserCredential extends Mock implements UserCredential {
  @override
  final User user;

  MockUserCredential({this.user});
}

class MockUserInfo extends Mock implements UserInfo {
  @override
  final String providerId;

  MockUserInfo({this.providerId});
}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockAuthenticator extends Mock implements Authenticator {
  @override
  Future<AuthResult> authenticate({@required AuthProvider provider, String username, String password}) async {
    return Future.value(AuthResult(provider: provider, credential: MockAuthCredential()));
  }

  @override
  Future<void> deauthenticate() {
    return Future.value();
  }
}
