import '../../../input/input.dart';

class AccountInputGroup extends InputGroup {
  final InputText firstname;
  final InputText lastname;

  AccountInputGroup({String? firstname, String? lastname})
      : firstname = InputText(value: firstname ?? ''),
        lastname = InputText(value: lastname ?? '');

  @override
  List<Input> get inputs => [firstname, lastname];
}
