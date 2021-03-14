import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../resources/firebase/analytics_service.dart';
import '../util/keys.dart';
import '../widgets/gl_icons.dart';
import '../widgets/gl_scaffold.dart';
import 'diary/diary_page.dart';
import 'pantry/pantry_page.dart';
import 'settings/settings_page.dart';

class MainTabs extends StatefulWidget {
  final AnalyticsService analyticsService;

  MainTabs({@required this.analyticsService});

  static Widget provisioned(BuildContext context) {
    return MainTabs(analyticsService: Provider.of<AnalyticsService>(context));
  }

  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> with SingleTickerProviderStateMixin, RouteAware {
  TabController _controller;
  int selectedIndex = 0;

  final tabs = [
    const Tab(
      key: Keys.diaryTab,
      text: 'Timeline',
      icon: Icon(GLIcons.diary),
    ),
    const Tab(
      key: Keys.pantryTab,
      text: 'Pantry',
      icon: Icon(GLIcons.pantry),
    ),
    const Tab(
      key: Keys.accountTab,
      text: 'Settings',
      icon: Icon(GLIcons.settings),
    ),
  ];

  final pages = [
    DiaryPage.provisioned(),
    PantryPage.provisioned(),
    SettingsPage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.analyticsService?.subscribeToRoute(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    widget.analyticsService?.unsubscribeFromRoute(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      vsync: this,
      length: tabs.length,
      initialIndex: selectedIndex,
    );
    _controller.addListener(() {
      setState(() {
        if (selectedIndex != _controller.index) {
          selectedIndex = _controller.index;
          _sendCurrentTabToAnalytics();
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
        controller: _controller,
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
      controller: _controller,
      children: pages,
    );
  }

  @override
  void didPush() => _sendCurrentTabToAnalytics();

  @override
  void didPopNext() => _sendCurrentTabToAnalytics();

  void _sendCurrentTabToAnalytics() => widget.analyticsService?.setCurrentScreen('${tabs[selectedIndex].text} Page');
}
