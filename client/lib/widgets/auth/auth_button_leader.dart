import 'package:flutter/widgets.dart';

class AuthButtonLeader extends StatelessWidget {
  static const double inset = 2.0;

  /// The full size of the leader.
  final double size;

  /// The leader widget.
  final Widget child;

  const AuthButtonLeader({this.size, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: const EdgeInsets.all(inset),
        child: ClipRRect(borderRadius: BorderRadius.circular((size - inset) * 0.5), child: child),
      ),
    );
  }
}
