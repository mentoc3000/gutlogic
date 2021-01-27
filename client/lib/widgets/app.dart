import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/auth.dart';
import '../blocs/gut_logic_bloc_observer.dart';
import '../pages/landing/landing_page.dart';
import '../resources/firebase/analytics_service.dart';
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
  final analyticsService = AnalyticsService();
  final firebaseCrashlytics = FirebaseCrashlytics.instance;
  final RemoteConfigService remoteConfigService;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  GutLogicApp({@required this.remoteConfigService}) {
    Bloc.observer = GutLogicBlocObserver(
      analyticsService: analyticsService,
      firebaseCrashlytics: firebaseCrashlytics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        Routes.provider(),
        Authenticator.provider(),
        RepositoryProvider.value(value: analyticsService),
        RepositoryProvider.value(value: firebaseCrashlytics),
        RepositoryProvider.value(value: remoteConfigService),
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      child: createRootWidget(),
    );
  }

  Widget createRootWidget() {
    return MaterialApp(
      home: LandingPage.provisioned(),
      builder: (context, child) {
        return GLWidgetConfig(
          child: Stack(
            children: [
              Container(color: GLColors.lightestGray),
              AuthenticatedResources(child: child, navigatorKey: _navigatorKey),
              if (AppConfig.of(context).buildmode != BuildMode.release) FlavorBanner(),
            ],
          ),
        );
      },
      theme: glTheme,
      navigatorKey: _navigatorKey,
      navigatorObservers: [
        analyticsService.observer,
      ],
    );
  }
}
