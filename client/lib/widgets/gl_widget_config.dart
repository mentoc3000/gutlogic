import 'package:flutter/widgets.dart';

/// GLWidgetConfig groups all of our top-level widget configurations.
class GLWidgetConfig extends StatelessWidget {
  final Widget child;

  const GLWidgetConfig({required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(behavior: SimpleScrollBehavior(), child: child);
  }
}

/// A simple scroll behavior without special effects.
class SimpleScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
