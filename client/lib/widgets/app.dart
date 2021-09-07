import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/landing/landing_page.dart';
import '../resources/firebase/analytics_service.dart';
import '../resources/user_repository.dart';
import '../routes/routes.dart';
import '../style/gl_colors.dart';
import '../style/gl_theme.dart';
import '../util/app_config.dart';
import 'authenticated_resources.dart';
import 'flavor_banner.dart';
import 'gl_widget_config.dart';

class GutLogicApp extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        Routes.provider(),
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      child: createRootWidget(context),
    );
  }

  Widget createRootWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocus(context),
      child: MaterialApp(
        home: LandingPage.provisioned(),
        builder: (context, child) {
          return GLWidgetConfig(
            child: Stack(
              children: [
                Container(color: GLColors.lightestGray),
                AuthenticatedResources(child: child ?? Container(), navigatorKey: _navigatorKey),
                if (context.read<AppConfig>().isDebug) FlavorBanner(),
              ],
            ),
          );
        },
        theme: glTheme,
        navigatorKey: _navigatorKey,
        navigatorObservers: [
          context.read<AnalyticsService>().observer(),
        ],
      ),
    );
  }

  /// Dismiss the keyboard when tapping outside of the focused widget
  void _unfocus(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
