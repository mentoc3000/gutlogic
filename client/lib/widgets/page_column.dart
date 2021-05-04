import 'package:flutter/widgets.dart';

/// A PageColumn combines several widgets to provide a scrollable column with support for expanded children.
class PageColumn extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  PageColumn({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: builder(context, constraints),
          ),
        );
      }),
    );
  }
}
