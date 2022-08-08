import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../resources/firebase/untyped_data.dart';
import '../serializers.dart';

part 'profile.g.dart';

abstract class Profile implements Built<Profile, ProfileBuilder> {
  String? get firstname;
  String? get lastname;

  Profile._(); // required by built_value

  factory Profile({
    String? firstname,
    String? lastname,
  }) = _$Profile._;

  static Profile? deserialize(UntypedData? value) {
    return serializers.deserializeWith(Profile.serializer, value);
  }

  static UntypedData? serialize(Profile value) {
    return serializers.serializeWith(Profile.serializer, value) as UntypedData;
  }

  static Serializer<Profile> get serializer => _$profileSerializer;
}
