import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

void verifyNamedParameter(void Function() func, String parameter, String value) =>
    expect(verify(Function.apply(func, [], {Symbol(parameter): captureAnyNamed(parameter)})).captured, [value]);
