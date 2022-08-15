import 'package:built_collection/built_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/blocs/diary/diary.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/blocs/user_cubit.dart';
import 'package:gutlogic/models/user/application_user.dart';
import 'package:gutlogic/pages/main_tabs.dart';
import 'package:gutlogic/resources/diary_repositories/bowel_movement_entry_repository.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_entry_repository.dart';
import 'package:gutlogic/resources/diary_repositories/symptom_entry_repository.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:gutlogic/resources/food_group_repository.dart';
import 'package:gutlogic/resources/irritant_service.dart';
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
import 'screenshots/screenshots_capture.dart';
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
  BowelMovementEntryRepository,
  FoodService,
  FoodGroupsRepository,
  DiaryRepository,
  IrritantService,
  MealElementRepository,
  MealEntryRepository,
  PantryService,
  SensitivityRepository,
  SymptomEntryRepository,
  User,
  UserRepository,
])
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Widget app;

  setUpAll(() async {
    // Mock user repository
    final user = ApplicationUser(firebaseUser: MockUser(), consented: true);
    final userRepository = MockUserRepository();
    when(userRepository.user).thenReturn(user);

    // Mock diary
    final diaryRepository = MockDiaryRepository();
    when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

    // Mock food service
    final foodService = MockFoodService();
    when(foodService.streamFood(any)).thenAnswer((_) => Stream.value(food));

    // Mock irritant repository
    final irritantService = MockIrritantService();
    when(irritantService.ofRef(any)).thenAnswer((_) => Future.value(irritants));
    when(irritantService.maxIntensity(any))
        .thenAnswer((invocation) => Future.value(vegetableMaxIntensities[invocation.positionalArguments[0]]));
    when(irritantService.intensityThresholds(any))
        .thenAnswer((realInvocation) => Future.value(intensityThresholds[realInvocation.positionalArguments[0]]));

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

    // Mock food groups
    final foodGroupsRepository = MockFoodGroupsRepository();
    when(foodGroupsRepository.groups()).thenAnswer((_) => Future.value(foodGroupNames));
    when(foodGroupsRepository.foods(group: 'Vegetables')).thenAnswer((_) => Future.value(vegetables));

    // remove debug banner for screenshots
    WidgetsApp.debugAllowBannerOverride = false;

    app = MultiProvider(
      providers: [
        Provider(create: (context) => Routes()),
        RepositoryProvider<BowelMovementEntryRepository>(create: (context) => bowelMovementEntryRepository),
        RepositoryProvider<DiaryRepository>(create: (context) => diaryRepository),
        RepositoryProvider<FoodService>(create: (context) => foodService),
        RepositoryProvider<FoodGroupsRepository>(create: (context) => foodGroupsRepository),
        RepositoryProvider<IrritantService>(create: (context) => irritantService),
        RepositoryProvider<MealElementRepository>(create: (context) => mealElementRepository),
        RepositoryProvider<MealEntryRepository>(create: (context) => mealEntryRepository),
        RepositoryProvider<PantryService>(create: (context) => pantryRepository),
        RepositoryProvider<SensitivityRepository>(create: (context) => sensitivityRepository),
        RepositoryProvider<SymptomEntryRepository>(create: (context) => symptomEntryRepository),
        RepositoryProvider<UserRepository>(create: (context) => userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => UserCubit(repository: context.read<UserRepository>())),
          BlocProvider(create: (context) => DiaryBloc(repository: context.read<DiaryRepository>())),
          BlocProvider(create: (context) => PantryBloc(pantryService: context.read<PantryService>())),
        ],
        child: ChangeNotifierProvider(
          create: (context) => SensitivityService(sensitivityRepository: context.read<SensitivityRepository>()),
          child: MainTabsPageWrapper(),
        ),
      ),
    );
  });

  testWidgets('screenshots', (tester) async {
    runApp(app);

    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Timeline'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Start filename with a number to put them in the correct order on the App Store
    await capture(binding, '3. timeline');

    await tester.tap(find.text(mealEntry2.mealElements[0].foodReference.name));
    await tester.pump();
    await tester.pumpAndSettle();

    await capture(binding, '4. meal');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bowel Movement'));
    await tester.pump();
    await tester.pumpAndSettle();

    await capture(binding, '5. bowel_movement');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text(symptomEntry.symptom.symptomType.name));
    await tester.pump();
    await tester.pumpAndSettle();

    await capture(binding, '6. symptom');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pantry'));
    await tester.pump();
    await tester.pumpAndSettle();

    await capture(binding, '0. pantry');

    await tester.tap(find.text(food.name));
    await tester.pump();
    await tester.pumpAndSettle();

    await capture(binding, '1. sensitivity');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Foods'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text(foodGroupName));
    await tester.pump();
    await tester.pumpAndSettle();

    await capture(binding, '2. browse');
  });
}
