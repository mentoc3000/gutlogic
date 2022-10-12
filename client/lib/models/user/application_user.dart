import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/auth.dart';

part 'application_user.g.dart';

abstract class ApplicationUser implements Built<ApplicationUser, ApplicationUserBuilder> {
  User get firebaseUser;

  /// The database ID of the user. All of the user data is indexed with this ID.
  String get id => firebaseUser.uid;

  /// The primary email associated with the user account.
  String? get email => firebaseUser.email;

  /// The username of the account.
  String? get username => email;

  /// True if the user email has been verified.
  bool get verified => firebaseUser.emailVerified;

  /// True if the user account is anonymous.
  bool get anonymous => firebaseUser.isAnonymous;

  /// The set of authentication services this user has connected.
  BuiltList<AuthProvider> get providers =>
      BuiltList.from(firebaseUser.providerData.map((p) => AuthProviderUtil.fromFirebaseProviderID(p.providerId)));

  /// True if the user has consented to the privacy policy and terms of use.
  bool get consented;

  String? get premiumStatus;

  /// True if premium subscription is active
  bool get hasActivePremiumSubscription => premiumStatus == 'ACTIVE';

  ApplicationUser._(); // required by built_value

  factory ApplicationUser({
    required User firebaseUser,
    required bool consented,
    required String? premiumStatus,
  }) = _$ApplicationUser._;

  Future<String> getToken() => firebaseUser.getIdToken();
}
