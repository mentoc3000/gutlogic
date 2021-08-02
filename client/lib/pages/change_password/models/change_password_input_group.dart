import '../../../input/input.dart';

class ChangePasswordInputGroup extends InputGroup {
  final InputText currentPassword = InputText();
  final InputText updatedPassword = InputText();

  @override
  List<Input> get inputs => [currentPassword, updatedPassword];
}
