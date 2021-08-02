import '../../../input/input.dart';

class ResetPasswordInputGroup extends InputGroup {
  final InputText email = InputText();

  @override
  List<Input> get inputs => [email];
}
