import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/auth.dart';
import '../blocs/gut_logic_bloc_observer.dart';
import '../pages/landing/landing_page.dart';
import '../resources/firebase/analytics_service.dart';
import '../resources/firebase/crashlytics_service.dart';
import '../resources/firebase/remote_config_service.dart';
import '../resources/user_repository.dart';
import '../routes/routes.dart';
import '../style/gl_colors.dart';
import '../style/gl_theme.dart';
import '../util/app_config.dart';
import 'authenticated_resources.dart';
import 'flavor_banner.dart';
import 'gl_widget_config.dart';

class GutLogicApp extends StatelessWidget {
  final AnalyticsService analytics;
  final CrashlyticsService crashlytics;
  final RemoteConfigService remoteConfigService;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  GutLogicApp({required this.analytics, required this.crashlytics, required this.remoteConfigService}) {
    Bloc.observer = GutLogicBlocObserver(analytics: analytics, crashlytics: crashlytics);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        Routes.provider(),
        Authenticator.provider(),
        RepositoryProvider.value(value: analytics),
        RepositoryProvider.value(value: crashlytics),
        RepositoryProvider.value(value: remoteConfigService),
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
                if (AppConfig.of(context)?.buildmode == BuildMode.debug) FlavorBanner(),
              ],
            ),
          );
        },
        theme: glTheme,
        navigatorKey: _navigatorKey,
        navigatorObservers: [
          analytics.observer(),
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
