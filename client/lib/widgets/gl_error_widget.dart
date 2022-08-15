import 'package:flutter/widgets.dart';

class GLErrorWidget extends StatelessWidget {
  final String? message;

  const GLErrorWidget({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message ?? 'Uh oh, something went wrong!'),
    );
  }
}
