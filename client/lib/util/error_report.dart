import 'package:meta/meta.dart';

class ErrorReport {
  final dynamic error;
  final StackTrace trace;

  ErrorReport({@required this.error, @required this.trace});
}
