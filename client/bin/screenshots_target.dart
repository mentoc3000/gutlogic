import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:gutlogic/blocs/authentication/authentication.dart';
import 'package:gutlogic/blocs/diary/diary.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/pages/main_tabs.dart';
import 'package:gutlogic/resources/diary_repositories/bowel_movement_entry_repository.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_entry_repository.dart';
import 'package:gutlogic/resources/diary_repositories/symptom_entry_repository.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:gutlogic/resources/irritant_repository.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_repository.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_service.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:gutlogic/routes/routes.dart';
import 'package:gutlogic/style/gl_theme.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'screenshots/screenshots_handler.dart' as screenshots;
import 'screenshots_target.mocks.dart';

class MainTabsPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: MainTabs(analytics: MockAnalyticsService()),
        theme: glTheme,
      );
}

@GenerateMocks([
  AnalyticsService,
  AuthenticationBloc,
  BowelMovementEntryRepository,
  FoodService,
  DiaryRepository,
  IrritantRepository,
  MealElementRepository,
  MealEntryRepository,
  PantryService,
  SensitivityRepository,
  SymptomEntryRepository,
  UserRepository,
])
void main() {
  // Pass the screenshots data request handler to the driver extension. This is required by the screenshot driver.
  enableFlutterDriverExtension(handler: screenshots.handler);

  // Mock user repository
  final userRepository = MockUserRepository();
  when(userRepository.user).thenReturn(user);

  // Mock authentication bloc
  final authenticationBloc = MockAuthenticationBloc();
  when(authenticationBloc.state).thenReturn(const Authenticated());

  // Mock diary
  final diaryRepository = MockDiaryRepository();
  when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

  // Mock food service
  final foodService = MockFoodService();
  when(foodService.streamFood(any)).thenAnswer((_) => Stream.value(food));

  // Mock irritant repository
  final irritantRepository = MockIrritantRepository();
  when(irritantRepository.ofRef(any)).thenAnswer((_) => Future.value(irritants));

  // Mock meal entry
  final mealEntryRepository = MockMealEntryRepository();
  when(mealEntryRepository.stream(any)).thenAnswer((_) => Stream.value(mealEntry2));

  // Mock mealElement
  final mealElementRepository = MockMealElementRepository();
  when(mealElementRepository.stream(any)).thenAnswer((_) => Stream.value(mealElement));

  // Mock bowel movement entry
  final bowelMovementEntryRepository = MockBowelMovementEntryRepository();
  when(bowelMovementEntryRepository.stream(any)).thenAnswer((_) => Stream.value(bowelMovementEntry));

  // Mock symptom entry
  final symptomEntryRepository = MockSymptomEntryRepository();
  when(symptomEntryRepository.stream(any)).thenAnswer((_) => Stream.value(symptomEntry));

  // Mock pantry
  final pantryRepository = MockPantryService();
  when(pantryRepository.streamAll()).thenAnswer((_) => Stream.value(pantryEntries));
  when(pantryRepository.stream(any)).thenAnswer((_) => Stream.value(pantryEntry));

  // Mock sensitivity
  final sensitivityRepository = MockSensitivityRepository();
  when(sensitivityRepository.streamAll()).thenAnswer((_) => Stream.value(BuiltMap(sensitivities)));

  // remove debug banner for screenshots
  WidgetsApp.debugAllowBannerOverride = false;

  final app = MultiRepositoryProvider(
    providers: [
      Routes.provider(),
      RepositoryProvider<BowelMovementEntryRepository>(create: (context) => bowelMovementEntryRepository),
      RepositoryProvider<DiaryRepository>(create: (context) => diaryRepository),
      RepositoryProvider<FoodService>(create: (context) => foodService),
      RepositoryProvider<IrritantRepository>(create: (context) => irritantRepository),
      RepositoryProvider<MealElementRepository>(create: (context) => mealElementRepository),
      RepositoryProvider<MealEntryRepository>(create: (context) => mealEntryRepository),
      RepositoryProvider<PantryService>(create: (context) => pantryRepository),
      RepositoryProvider<SensitivityRepository>(create: (context) => sensitivityRepository),
      RepositoryProvider<SymptomEntryRepository>(create: (context) => symptomEntryRepository),
      RepositoryProvider<UserRepository>(create: (context) => userRepository),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(create: (context) => authenticationBloc),
        BlocProvider(create: (context) => DiaryBloc(repository: context.read<DiaryRepository>())),
        BlocProvider(create: (context) => PantryBloc(pantryService: context.read<PantryService>())),
      ],
      child: ChangeNotifierProvider(
        create: (context) => SensitivityService(sensitivityRepository: context.read<SensitivityRepository>()),
        child: MainTabsPageWrapper(),
      ),
    ),
  );

  runApp(app);
}
