import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../auth/auth.dart';
import '../blocs/simple_bloc_delegate.dart';
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
import 'multi_resource_provider.dart';

class GutLogicApp extends StatelessWidget {
  final analyticsService = AnalyticsService();
  final firebaseCrashlytics = FirebaseCrashlytics.instance;
  final RemoteConfigService remoteConfigService;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  GutLogicApp({@required this.remoteConfigService}) {
    BlocSupervisor.delegate = SimpleBlocDelegate(
      analyticsService: analyticsService,
      firebaseCrashlytics: firebaseCrashlytics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiResourceProvider(
      services: [
        Authenticator.provider(),
        Routes.provider(),
        Provider.value(value: analyticsService),
        Provider.value(value: firebaseCrashlytics),
        Provider.value(value: remoteConfigService),
      ],
      repos: [
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
