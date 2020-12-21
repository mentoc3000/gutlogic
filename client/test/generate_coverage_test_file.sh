#!/bin/sh
file=test/coverage_helper_test.dart
echo "// Helper file to make coverage work for all dart files\n" > $file
echo "// ignore_for_file: unused_import" >> $file
find lib -name '*.dart' ! -name '*.g.dart' | cut -c4- | awk '{printf "import '\''package:gutlogic%s'\'';\n", $1}' >> $file
echo "void main(){}" >> $file