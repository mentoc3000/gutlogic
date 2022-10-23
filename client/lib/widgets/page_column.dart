import 'package:flutter/widgets.dart';

/// A ConstrainedScrollView combines several widgets to provide a scrollable container where children can be expanded
/// up to the maximum height of the view.
class ConstrainedScrollView extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  const ConstrainedScrollView({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight, minWidth: constraints.maxWidth),
          child: IntrinsicHeight(child: builder(context, constraints)),
        ),
      );
    });
  }
}
