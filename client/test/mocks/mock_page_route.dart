import 'package:flutter/widgets.dart';

class MockPageRoute extends PageRouteBuilder {
  final Key key;

  MockPageRoute({this.key}) : super(pageBuilder: _generatePageBuilder(key));

  static RoutePageBuilder _generatePageBuilder(Key key) {
    return (BuildContext context, Animation a, Animation b) => Container(key: key);
  }
}
