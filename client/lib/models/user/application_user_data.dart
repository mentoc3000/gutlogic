import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'application_user_data.g.dart';

abstract class ApplicationUserData implements Built<ApplicationUserData, ApplicationUserDataBuilder> {
  static Serializer<ApplicationUserData> get serializer => _$applicationUserDataSerializer;

  /// True if the user has consented to the privacy policy and terms of use.
  bool? get consented;

  /// Status of premium subscription
  String? get premiumStatus;

  ApplicationUserData._(); // required by built_value

  factory ApplicationUserData({
    required bool consented,
    required String? premiumStatus,
  }) = _$ApplicationUserData._;
}
