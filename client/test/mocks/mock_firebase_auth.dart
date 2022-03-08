import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final _currentUserStream = BehaviorSubject<User?>();

  @override
  User? get currentUser => _currentUserStream.value;

  @override
  Stream<User?> userChanges() => _currentUserStream.asBroadcastStream();

  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) async {
    final user = FakeUser(_currentUserStream);

    _currentUserStream.add(user);

    return FakeUserCredential(user: user);
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    final user = FakeUser(_currentUserStream);

    user.isAnonymous = true;

    _currentUserStream.add(user);

    return FakeUserCredential(user: user);
  }

  @override
  Future<void> signOut() async {
    _currentUserStream.add(null);
  }
}

class FakeUser extends Fake implements User {
  @override
  String uid = 'fake';

  @override
  String email = 'fake@fake.com';

  @override
  bool emailVerified = true;

  @override
  bool isAnonymous = false;

  @override
  List<FakeUserInfo> providerData = [FakeUserInfo(providerId: 'firebase')];

  final BehaviorSubject<User?> _currentUserStream;

  FakeUser(BehaviorSubject<User?> firebaseAuthUser) : _currentUserStream = firebaseAuthUser;

  @override
  Future<UserCredential> linkWithCredential(AuthCredential? cred) async {
    _currentUserStream.add(this);
    return FakeUserCredential(user: this);
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential? cred) async {
    _currentUserStream.add(this);
    return FakeUserCredential(user: this);
  }

  @override
  Future<void> delete() async {
    _currentUserStream.add(null);
  }
}

class FakeAuthCredential extends Fake implements AuthCredential {
  FakeAuthCredential();
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final FakeUser? user;

  FakeUserCredential({required this.user});
}

class FakeUserInfo extends Fake implements UserInfo {
  @override
  final String providerId;

  FakeUserInfo({required this.providerId});
}
