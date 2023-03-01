import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../resources/app_review.dart';
import '../resources/firebase/analytics_service.dart';
import '../util/keys.dart';
import '../widgets/gl_icons.dart';
import '../widgets/gl_scaffold.dart';
import 'analysis/analysis_page.dart';
import 'browse/browse_page.dart';
import 'diary/diary_page.dart';
import 'pantry/pantry_page.dart';

class MainTabs extends StatefulWidget {
  final AnalyticsService analytics;

  const MainTabs._({required this.analytics});

  static Widget provisioned(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: MainTabs._(
        analytics: Provider.of<AnalyticsService>(context),
      ),
    );
  }

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> with SingleTickerProviderStateMixin, RouteAware {
  final tabs = [
    const Tab(
      key: Keys.pantryTab,
      text: 'Pantry',
      icon: Icon(GLIcons.pantry),
    ),
    const Tab(
      key: Keys.diaryTab,
      text: 'Timeline',
      icon: Icon(GLIcons.diary),
    ),
    const Tab(
      key: Keys.browseTab,
      text: 'Foods',
      icon: Icon(GLIcons.browse),
    ),
    const Tab(
      text: 'Analysis',
      icon: Icon(GLIcons.analysis),
    ),
  ];

  final pages = [
    PantryPage.provisioned(),
    DiaryPage.provisioned(),
    const BrowsePage(),
    const AnalysisPage(),
  ];

  @override
  void initState() {
    super.initState();
    activateReviewManager();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute<Widget>) widget.analytics.subscribeToRoute(this, route);
  }

  @override
  void dispose() {
    widget.analytics.unsubscribeFromRoute(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      body: buildTabBarView(context),
      bottomNavigationBar: buildTabBar(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget buildTabBar(BuildContext context) {
    return SafeArea(
      child: TabBar(
        tabs: tabs,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.all(5.0),
        indicatorColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget buildTabBarView(BuildContext context) {
    return TabBarView(
      children: pages,
    );
  }
}
