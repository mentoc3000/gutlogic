import 'package:built_value/built_value.dart';
import '../model_interfaces.dart';

part 'diary_entry.g.dart';

@BuiltValue(instantiable: false)
abstract class DiaryEntry with Ided, Dated, Noted {
  DiaryEntry rebuild(void Function(DiaryEntryBuilder) updates);
  DiaryEntryBuilder toBuilder();
}
