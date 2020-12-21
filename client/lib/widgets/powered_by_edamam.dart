import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';

class PoweredByEdamam extends StatelessWidget {
  final Widget child;

  const PoweredByEdamam({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Stack(
    return Column(
      children: [
        Expanded(child: child),
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset('assets/powered_by_edamam_transparent.png'),
        ),
      ],
    );
  }
}
