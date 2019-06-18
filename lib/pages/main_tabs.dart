import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gut_ai/resources/app_sync_service.dart';
import 'account_page.dart';
import 'food_search_page.dart';
import 'diary_page.dart';
import '../widgets/placeholder_widget.dart';
import '../blocs/tab_bloc.dart';
import '../blocs/tab_state.dart';
import '../blocs/tab_event.dart';
import '../blocs/food_bloc.dart';
import '../blocs/medicine_bloc.dart';
import '../blocs/diary_entry_bloc.dart';
import '../blocs/symptom_type_bloc.dart';
import '../resources/user_service.dart';
import '../resources/food_repository.dart';
import '../resources/medicine_repository.dart';
import '../resources/symptom_type_repository.dart';
import '../resources/diary_entry_repository.dart';

class Tabbed extends StatefulWidget {
  static String tag = 'tabbed-page';
  @override
  _TabbedState createState() => _TabbedState();
}

class _TabbedState extends State<Tabbed> {
  TabBloc _tabBloc;
  FoodBloc _foodBloc;
  MedicineBloc _medicineBloc;
  SymptomTypeBloc _symptomTypeBloc;
  DiaryEntryBloc _diaryEntriesBloc;

  @override
  void initState() {
    final userService = UserService();
    final session = userService.getSession();
    AppSyncService appSyncService = AppSyncService(session);

    _tabBloc = TabBloc();

    FoodRepository foodRepository = FoodRepository(appSyncService);
    _foodBloc = FoodBloc(foodRepository);

    MedicineRepository medicineRepository = MedicineRepository();
    _medicineBloc = MedicineBloc(medicineRepository);

    SymptomTypeRepository symptomTypeRepository = SymptomTypeRepository();
    _symptomTypeBloc = SymptomTypeBloc(symptomTypeRepository);

    DiaryEntryRepository diaryEntriesRepository = DiaryEntryRepository();
    _diaryEntriesBloc = DiaryEntryBloc(diaryEntriesRepository);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<FoodBloc>(bloc: _foodBloc),
        BlocProvider<MedicineBloc>(bloc: _medicineBloc),
        BlocProvider<SymptomTypeBloc>(bloc: _symptomTypeBloc),
        BlocProvider<DiaryEntryBloc>(bloc: _diaryEntriesBloc),
      ],
      child: BlocBuilder(
        bloc: _tabBloc,
        builder: (BuildContext context, AppTab appTab) {
          return Scaffold(
            body: _buildBody(appTab),
            bottomNavigationBar: TabSelector(
              activeTab: appTab,
              onTabSelected: (tab) => _tabBloc.dispatch(UpdateTab(tab)),
            ),
          );
        },
      ),
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
