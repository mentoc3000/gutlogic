import 'package:logger/logger.dart';
import 'package:logger/src/printers/simple_printer.dart';

final Logger logger = Logger(
  printer: SimplePrinter(),
  filter: null,
  output: null,
);
