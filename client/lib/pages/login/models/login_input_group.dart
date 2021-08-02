import '../../../input/input.dart';

class LoginInputGroup extends InputGroup {
  final InputText username = InputText();
  final InputText password = InputText();

  @override
  List<Input> get inputs => [username, password];
}
