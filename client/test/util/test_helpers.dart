import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void verifyNamedParameter(Function func, String parameter, String value) {
  expect(verify(Function.apply(func, [], {Symbol(parameter): captureAnyNamed(parameter)})).captured, [value]);
}
