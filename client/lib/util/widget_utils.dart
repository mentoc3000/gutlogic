import 'package:flutter/widgets.dart';

abstract class WidgetUtils {
  static List<Widget> separate(List<Widget> widgets, {required Widget separator}) {
    return widgets.isNotEmpty ? widgets.expand((w) => [w, separator]).take(widgets.length * 2 - 1).toList() : [];
  }
}
