import 'package:flutter/material.dart';

class GLScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool extendBody;

  const GLScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.extendBody = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: !extendBody ? SafeArea(child: body) : body,
      floatingActionButton: floatingActionButton,
      // floatingActionButtonLocation:,
      // floatingActionButtonAnimator:,
      // persistentFooterButtons:,
      // drawer:,
      // endDrawer:,
      bottomNavigationBar: bottomNavigationBar,
      // bottomSheet:,
      backgroundColor: backgroundColor,
      // resizeToAvoidBottomPadding: ,
      // resizeToAvoidBottomInset: ,
      // primary: true,
      // drawerDragStartBehavior: DragStartBehavior.start,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBody,
      // drawerScrimColor: ,
      // drawerEdgeDragWidth: ,
      // drawerEnableOpenDragGesture: true,
      // endDrawerEnableOpenDragGesture: true,
    );
  }
}
