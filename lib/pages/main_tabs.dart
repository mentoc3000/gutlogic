import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'account_page.dart';
import 'food_search_page.dart';
import 'diary_page.dart';
import '../widgets/placeholder_widget.dart';
import '../blocs/tab_bloc.dart';
import '../blocs/tab_state.dart';
import '../blocs/tab_event.dart';

class Tabbed extends StatefulWidget {
  static String tag = 'tabbed-page';
  @override
  _TabbedState createState() => _TabbedState();
}

class _TabbedState extends State<Tabbed> {
  TabBloc _tabBloc = TabBloc();
  // int _currentTab = 0;

  // final List<CustomTab> tabs = <CustomTab>[
  //   CustomTab(
  //     child: DiaryPage(),
  //   ),
  //   CustomTab(
  //     child: FoodSearchPage(),
  //   ),
  //   CustomTab(
  //     child: PlaceholderWidget(Colors.red),
  //   ),
  //   CustomTab(
  //     child: AccountPage(),
  //   ),
  // ];

  // Future<Null> _setTab(int index) async {
  //   if (_currentTab == index) {
  //     if (Navigator.of(tabs[index].tabContext).canPop()) {
  //       Navigator.of(tabs[index].tabContext)
  //           .popUntil((Route<dynamic> r) => r.isFirst);
  //     }
  //     return;
  //   }
  //   setState(() {
  //     _currentTab = index;
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Material(
  //     child: Column(
  //       children: <Widget>[
  //         _buildStack(),
  //         _buildTabs(),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _tabBloc,
      builder: (BuildContext context, AppTab appTab) {
        // TODO: BlocProviderTree can be included here
        return Scaffold(
          body: _buildBody(appTab),
          bottomNavigationBar: TabSelector(
            activeTab: appTab,
            onTabSelected: (tab) => _tabBloc.dispatch(UpdateTab(tab)),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppTab appTab) {
    Widget body;
    switch (appTab) {
      case AppTab.diary:
        {
          body = DiaryPage();
        }
        break;

      case AppTab.search:
        {
          body = FoodSearchPage();
        }
        break;

      case AppTab.chat:
        {
          body = PlaceholderWidget(Colors.red);
        }
        break;

      case AppTab.account:
        {
          body = AccountPage();
        }
        break;

      default:
        {
          body = DiaryPage();
        }
        break;
    }
    return body;
  }

  // Widget _buildStack() {
  //   return Expanded(
  //     child: Container(
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //       ),
  //       child: IndexedStack(
  //         sizing: StackFit.expand,
  //         index: _currentTab,
  //         children: tabs,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTabs() {
  //   return SafeArea(
  //     top: false,
  //     child: Container(
  //       decoration: const BoxDecoration(
  //         color: Colors.transparent,
  //         border: Border(
  //           top: BorderSide(color: Color.fromRGBO(58, 66, 86, 0.3)),
  //         ),
  //       ),
  //       height: 55.0,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           IconButton(
  //             iconSize: 30.0,
  //             color: _currentTab == 0
  //                 ? Color.fromRGBO(58, 66, 86, 1.0)
  //                 : Color.fromRGBO(58, 66, 86, 0.3),
  //             icon: const Icon(Icons.subject),
  //             onPressed: () {
  //               _setTab(0);
  //             },
  //           ),
  //           IconButton(
  //             iconSize: 30.0,
  //             color: _currentTab == 1
  //                 ? Color.fromRGBO(58, 66, 86, 1.0)
  //                 : Color.fromRGBO(58, 66, 86, 0.3),
  //             icon: const Icon(Icons.search),
  //             onPressed: () {
  //               _setTab(1);
  //             },
  //           ),
  //           IconButton(
  //             iconSize: 30.0,
  //             color: _currentTab == 2
  //                 ? Color.fromRGBO(58, 66, 86, 1.0)
  //                 : Color.fromRGBO(58, 66, 86, 0.3),
  //             icon: const Icon(Icons.web_asset),
  //             onPressed: () {
  //               _setTab(2);
  //             },
  //           ),
  //           IconButton(
  //             iconSize: 30.0,
  //             color: _currentTab == 3
  //                 ? Color.fromRGBO(58, 66, 86, 1.0)
  //                 : Color.fromRGBO(58, 66, 86, 0.3),
  //             icon: const Icon(Icons.person),
  //             onPressed: () {
  //               _setTab(3);
  //             },
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class TabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  TabSelector({
    Key key,
    @required this.activeTab,
    @required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.blue,
      ),
      child: BottomNavigationBar(
        currentIndex: AppTab.values.indexOf(activeTab),
        onTap: (index) => onTabSelected(AppTab.values[index]),
        items: AppTab.values.map((tab) {
          BottomNavigationBarItem item;
          switch (tab) {
            case (AppTab.diary):
              {
                item = BottomNavigationBarItem(
                  icon: const Icon(Icons.subject),
                  title: Text('Diary'),
                );
              }
              break;

            case (AppTab.search):
              {
                item = BottomNavigationBarItem(
                  icon: const Icon(Icons.search),
                  title: Text('Search'),
                );
              }
              break;

            case (AppTab.chat):
              {
                item = BottomNavigationBarItem(
                  icon: const Icon(Icons.chat),
                  title: Text('Chat'),
                );
              }
              break;

            case (AppTab.account):
              {
                item = BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  title: Text('Account'),
                );
              }
              break;

            default:
              {
                item = BottomNavigationBarItem(
                  icon: const Icon(Icons.error),
                  title: Text('Invalid'),
                );
              }
              break;
          }
          return item;
        }).toList(),
      ),
    );
  }
}
