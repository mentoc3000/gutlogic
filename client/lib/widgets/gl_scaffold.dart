import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../style/gl_theme.dart';

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

  /// Correct the status bar brightness when there is no app bar.
  /// Otherwise status bar is incorrectly colored when on login screen on physical iOS devices
  void setStatusBarBrightness() {
    Brightness brightness;
    if (appBar == null) {
      brightness = brightnessOnBackground;
    } else {
      brightness = brightnessOnPrimary;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarBrightness: brightness));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: improve status bar timing
    setStatusBarBrightness();

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
