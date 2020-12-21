import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

import '../auth/auth_provider.dart';
import 'serializers.dart';

part 'application_user.g.dart';

abstract class ApplicationUser implements Built<ApplicationUser, ApplicationUserBuilder> {
  /// The database ID of the user. All of the user data is indexed with this ID.
  String get id;

  /// The username of the account.
  String get username => email;

  /// The primary email associated with the user account.
  String get email;

  /// True if the user email has been verified.
  bool get verified;

  /// True if the user has consented to the privacy policy and terms of use.
  bool get consented;

  /// The set of authentication providers this user has connected.
  BuiltList<AuthProvider> get providers;

  @nullable
  String get firstname;

  @nullable
  String get lastname;

  @nullable
  DateTime get birthdate;

  Map<String, dynamic> toJSON() {
    return serializers.serializeWith(_$applicationUserSerializer, this);
  }

  factory ApplicationUser.fromJSON(Map<String, dynamic> json) {
    // TODO figure out a better way to handle default values
    if (json.containsKey('consented') == false) json['consented'] = false;

    return serializers.deserializeWith(_$applicationUserSerializer, json);
  }

  factory ApplicationUser({
    @required String id,
    @required String email,
    @required bool verified,
    @required bool consented,
    @required BuiltList<AuthProvider> providers,
    String firstname,
    String lastname,
    DateTime birthdate,
  }) = _$ApplicationUser._;

  // built_value boilerplate
  ApplicationUser._();
  static Serializer<ApplicationUser> get serializer => _$applicationUserSerializer;
  // built_value boilerplate
}
