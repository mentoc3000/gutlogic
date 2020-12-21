import 'package:flutter/widgets.dart';

/// GLWidgetConfig groups all of our top-level widget configurations.
class GLWidgetConfig extends StatelessWidget {
  final Widget child;

  GLWidgetConfig({this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(behavior: SimpleScrollBehavior(), child: child);
  }
}

/// A simple scroll behavior without special effects.
class SimpleScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axis) {
    return child;
  }
}
