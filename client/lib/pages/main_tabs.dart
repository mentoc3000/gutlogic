import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../resources/firebase/analytics_service.dart';
import '../util/keys.dart';
import '../widgets/gl_icons.dart';
import '../widgets/gl_scaffold.dart';
import 'browse/browse_page.dart';
import 'diary/diary_page.dart';
import 'pantry/pantry_page.dart';

class MainTabs extends StatefulWidget {
  final AnalyticsService analytics;
  static const initialTab = 1;

  const MainTabs({required this.analytics});

  static Widget provisioned(BuildContext context) {
    return MainTabs(analytics: Provider.of<AnalyticsService>(context));
  }

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> with SingleTickerProviderStateMixin, RouteAware {
  late final TabController controller;
  int selectedIndex = MainTabs.initialTab;

  final tabs = [
    const Tab(
      key: Keys.diaryTab,
      text: 'Timeline',
      icon: Icon(GLIcons.diary),
    ),
    const Tab(
      key: Keys.browseTab,
      text: 'Browse',
      icon: Icon(GLIcons.browse),
    ),
    const Tab(
      key: Keys.pantryTab,
      text: 'Pantry',
      icon: Icon(GLIcons.pantry),
    ),
  ];

  final pages = [
    DiaryPage.provisioned(),
    const BrowsePage(),
    PantryPage.provisioned(),
  ];

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
  void initState() {
    super.initState();
    controller = TabController(
      vsync: this,
      length: tabs.length,
      initialIndex: selectedIndex,
    );
    controller.addListener(() {
      setState(() {
        if (selectedIndex != controller.index) {
          selectedIndex = controller.index;
          sendCurrentTabToAnalytics();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: GLScaffold(
        body: buildTabBarView(context),
        bottomNavigationBar: buildTabBar(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget buildTabBar(BuildContext context) {
    return SafeArea(
      child: TabBar(
        controller: controller,
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
      controller: controller,
      children: pages,
    );
  }

  @override
  void didPush() => sendCurrentTabToAnalytics();

  @override
  void didPopNext() => sendCurrentTabToAnalytics();

  void sendCurrentTabToAnalytics() => widget.analytics.setCurrentScreen('${tabs[selectedIndex].text} Page');
}
