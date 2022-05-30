import 'package:flutter/widgets.dart';

class MockPageRoute extends PageRouteBuilder<Widget> {
  final Key key;

  MockPageRoute({required this.key}) : super(pageBuilder: _generatePageBuilder(key));

  static RoutePageBuilder _generatePageBuilder(Key key) {
    return (BuildContext context, Animation<dynamic> a, Animation<dynamic> b) => Container(key: key);
  }
}
