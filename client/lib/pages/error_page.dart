import 'package:flutter/widgets.dart';

import '../widgets/gl_scaffold.dart';

class ErrorPage extends StatelessWidget {
  final String? message;

  ErrorPage({this.message});

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      body: Center(
        child: Text(message ?? 'Uh oh, something went wrong!'),
      ),
    );
  }
}
