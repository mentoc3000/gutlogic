import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Provides a FocusHistory to the child tree.
class FocusHistory extends StatelessWidget {
  final Widget child;

  const FocusHistory({required this.child});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => FocusHistoryState(),
      child: Builder(
        builder: (context) {
          return Focus(
            child: child,
            onFocusChange: (focus) => context.read<FocusHistoryState>().onFocusChanged(focus),
          );
        },
      ),
    );
  }

  static FocusHistoryState of(BuildContext context) => context.read<FocusHistoryState>();
}

class FocusHistoryState {
  bool _hasFocus = false;
  bool _hadFocus = false;

  /// True if the FocusHistoryState currently has focus.
  bool get hasFocus => _hasFocus;

  /// True if the FocusHistoryState has ever had focus.
  bool get hadFocus => _hadFocus;

  /// True if the FocusHistoryState had focus and then lost it.
  bool get blurred => _hadFocus && (_hasFocus == false);

  FocusHistoryState();

  // ignore: avoid_positional_boolean_parameters
  void onFocusChanged(bool focus) {
    _hasFocus = focus;
    _hadFocus = _hadFocus || focus;
  }
}
