import 'package:flutter/material.dart';

class GLScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const GLScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: body),
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
      // extendBody: false,
      // extendBodyBehindAppBar: false,
      // drawerScrimColor: ,
      // drawerEdgeDragWidth: ,
      // drawerEnableOpenDragGesture: true,
      // endDrawerEnableOpenDragGesture: true,
    );
  }
}
