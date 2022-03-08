import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../auth/auth.dart';

part 'application_user.g.dart';

abstract class ApplicationUser implements Built<ApplicationUser, ApplicationUserBuilder> {
  /// The database ID of the user. All of the user data is indexed with this ID.
  String get id;

  /// The primary email associated with the user account.
  String? get email;

  /// The username of the account.
  String? get username => email;

  /// True if the user email has been verified.
  bool get verified;

  /// True if the user has consented to the privacy policy and terms of use.
  bool get consented;

  /// True if the user account is anonymous.
  bool get anonymous;

  /// The set of authentication services this user has connected.
  BuiltList<AuthProvider> get providers;

  ApplicationUser._(); // required by built_value

  factory ApplicationUser({
    required String id,
    required String? email,
    required bool verified,
    required bool consented,
    required bool anonymous,
    required BuiltList<AuthProvider> providers,
  }) = _$ApplicationUser._;
}
