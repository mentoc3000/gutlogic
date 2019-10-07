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
import '../resources/user_repository.dart';
import '../resources/food_repository.dart';
import '../resources/medicine_repository.dart';
import '../resources/symptom_type_repository.dart';
import '../resources/diary_entry_repository.dart';
import '../resources/id_service.dart';

// TODO: change to stateless widget
class Tabbed extends StatefulWidget {
  final UserRepository userRepository;

  Tabbed({@required this.userRepository});

  static String tag = 'tabbed-page';
  @override
  _TabbedState createState() => _TabbedState();
}

class _TabbedState extends State<Tabbed> {
  TabBloc _tabBloc;
  FoodBloc _foodBloc;
  MedicineBloc _medicineBloc;
  SymptomTypeBloc _symptomTypeBloc;
  DiaryEntryBloc _diaryEntryBloc;

  Widget _diaryPage;
  Widget _foodSearchPage;
  Widget _chatPage;
  Widget _accountPage;

  @override
  void initState() {
    final session = widget.userRepository.session;
    AppSyncService appSyncService = AppSyncService(session);
    IdService idService = IdService(widget.userRepository);

    _tabBloc = TabBloc();

    FoodRepository foodRepository = FoodRepository(appSyncService);
    _foodBloc = FoodBloc(foodRepository);

    MedicineRepository medicineRepository = MedicineRepository();
    _medicineBloc = MedicineBloc(medicineRepository);

    SymptomTypeRepository symptomTypeRepository = SymptomTypeRepository();
    _symptomTypeBloc = SymptomTypeBloc(symptomTypeRepository);

    DiaryEntryRepository diaryEntriesRepository = DiaryEntryRepository();
    _diaryEntryBloc = DiaryEntryBloc(diaryEntriesRepository, idService);

    _diaryPage = MaterialApp(
      home: Scaffold(
        body: DiaryPage(),
      ),
    );

    _foodSearchPage = MaterialApp(
      home: Scaffold(
        body: FoodSearchPage(),
      ),
    );

    _chatPage = MaterialApp(
      home: Scaffold(
        body: PlaceholderWidget(
          Colors.red,
        ),
      ),
    );

    _accountPage = MaterialApp(
      home: Scaffold(
        body: AccountPage(
          userRepository: widget.userRepository,
        ),
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<FoodBloc>(bloc: _foodBloc),
        BlocProvider<MedicineBloc>(bloc: _medicineBloc),
        BlocProvider<SymptomTypeBloc>(bloc: _symptomTypeBloc),
        BlocProvider<DiaryEntryBloc>(bloc: _diaryEntryBloc),
      ],
      child: BlocBuilder(
        bloc: _tabBloc,
        builder: (BuildContext context, AppTab appTab) {
          // Scaffold to provide bottomNavigationBar
          return Scaffold(
            // MaterialApp to provide routing while persisting bottom bar
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
    // Allow separate navigation within each tab
    return Stack(
      children: <Widget>[
        Offstage(
          offstage: appTab != AppTab.diary,
          child: _diaryPage,
        ),
        Offstage(
          offstage: appTab != AppTab.search,
          child: _foodSearchPage,
        ),
        Offstage(
          offstage: appTab != AppTab.chat,
          child: _chatPage,
        ),
        Offstage(
          offstage: appTab != AppTab.account,
          child: _accountPage,
        ),
      ],
    );
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
