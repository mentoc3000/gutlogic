import 'dart:io' show Platform;

import 'package:built_collection/built_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/blocs/subscription/subscription.dart';
import 'package:gutlogic/models/preferences/preferences.dart';
import 'package:gutlogic/resources/analysis_service.dart';
import 'package:gutlogic/resources/preferences_service.dart';
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
import 'package:rxdart/rxdart.dart';

import 'data.dart';
import 'screenshots/screenshots_capture.dart';
import 'screenshots_target.mocks.dart';

class MainTabsPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainTabs.provisioned(context),
      theme: glTheme,
    );
  }
}

@GenerateMocks([
  AnalyticsService,
  AnalysisService,
  BowelMovementEntryRepository,
  FoodService,
  FoodGroupsRepository,
  DiaryRepository,
  IrritantService,
  MealElementRepository,
  MealEntryRepository,
  PantryService,
  PreferencesService,
  SensitivityRepository,
  SubscriptionCubit,
  SymptomEntryRepository,
  User,
  UserRepository,
])
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final preferencesService;
  final preferences = Preferences(irritantsExcluded: BuiltSet({'Sorbitol'}));

  late Widget app;

  setUpAll(() async {
    // Mock user repository
    final user = ApplicationUser(firebaseUser: MockUser(), consented: true, premiumStatus: 'ACTIVE');
    final userRepository = MockUserRepository();
    when(userRepository.user).thenReturn(user);
    when(userRepository.stream).thenAnswer((_) => BehaviorSubject.seeded(user));

    // Mock diary
    final diaryRepository = MockDiaryRepository();
    when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

    // Mock food service
    final foodService = MockFoodService();
    when(foodService.streamFood(any)).thenAnswer((_) => Stream.value(elementaryFood));
    when(foodService.streamFood(compoundFood.toFoodReference())).thenAnswer((_) => Stream.value(compoundFood));

    // Mock irritant repository
    final irritantService = MockIrritantService();
    when(irritantService.ofRef(any)).thenAnswer((_) => Stream.value(irritants));
    when(irritantService.ofRef(any, usePreferences: anyNamed('usePreferences'))).thenAnswer((_) {
      return Stream.value(irritants);
    });
    when(irritantService.maxIntensity(any)).thenAnswer((invocation) {
      return Stream.value(dosesMaxIntensities[invocation.positionalArguments[0]]);
    });
    when(irritantService.maxIntensity(any, usePreferences: anyNamed('usePreferences'))).thenAnswer((invocation) {
      return Stream.value(dosesMaxIntensities[invocation.positionalArguments[0]]);
    });
    when(irritantService.intensityThresholds(any)).thenAnswer((invocation) {
      return Future.value(intensityThresholds[invocation.positionalArguments[0]]);
    });
    when(irritantService.ofIngredient(any)).thenAnswer((invocation) {
      return Stream.value(ingredientIrritantMap[invocation.positionalArguments[0]]);
    });
    when(irritantService.ofIngredient(any, usePreferences: anyNamed('usePreferences'))).thenAnswer((invocation) {
      return Stream.value(ingredientIrritantMap[invocation.positionalArguments[0]]);
    });
    when(irritantService.ofIngredients(any)).thenAnswer((_) {
      return Stream.value(null);
    });
    when(irritantService.ofIngredients(any, usePreferences: anyNamed('usePreferences'))).thenAnswer((_) {
      return Stream.value(null);
    });

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

    // Mock analyses
    final analysisService = MockAnalysisService();
    when(analysisService.foodCountByIrritantAndLevel()).thenAnswer((_) => Stream.value(foodCountByIrritant));
    when(analysisService.recentSeverity(count: anyNamed('count'))).thenAnswer((_) => Stream.value(recentSeverities));
    when(analysisService.symptomTypeCount(since: anyNamed('since'))).thenAnswer((_) => Stream.value(symptomTypeCount));
    when(analysisService.diaryStreak(count: anyNamed('count'))).thenAnswer((_) => Stream.value(diaryStreak));

    // Mock preferences
    preferencesService = MockPreferencesService();
    when(preferencesService.stream).thenAnswer((_) => BehaviorSubject<Preferences>()..add(Preferences()));
    when(preferencesService.value).thenReturn(Preferences());

    // remove debug banner for screenshots
    WidgetsApp.debugAllowBannerOverride = false;

    app = MultiProvider(
      providers: [
        Provider(create: (context) => Routes()),
        RepositoryProvider<AnalyticsService>(create: (context) => MockAnalyticsService()),
        RepositoryProvider<BowelMovementEntryRepository>(create: (context) => bowelMovementEntryRepository),
        RepositoryProvider<DiaryRepository>(create: (context) => diaryRepository),
        RepositoryProvider<FoodService>(create: (context) => foodService),
        RepositoryProvider<FoodGroupsRepository>(create: (context) => foodGroupsRepository),
        RepositoryProvider<IrritantService>(create: (context) => irritantService),
        RepositoryProvider<MealElementRepository>(create: (context) => mealElementRepository),
        RepositoryProvider<MealEntryRepository>(create: (context) => mealEntryRepository),
        RepositoryProvider<PantryService>(create: (context) => pantryRepository),
        RepositoryProvider<PreferencesService>(create: (context) => preferencesService),
        RepositoryProvider<SensitivityRepository>(create: (context) => sensitivityRepository),
        RepositoryProvider<SymptomEntryRepository>(create: (context) => symptomEntryRepository),
        RepositoryProvider<UserRepository>(create: (context) => userRepository),
        RepositoryProvider<AnalysisService>(create: (context) => analysisService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => UserCubit(repository: context.read<UserRepository>())),
          BlocProvider(create: (context) => DiaryBloc(repository: context.read<DiaryRepository>())),
          BlocProvider(create: (context) => PantryBloc(pantryService: context.read<PantryService>())),
          BlocProvider(create: SubscriptionCubit.fromContext)
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

    if (Platform.isAndroid) {
      // Android-specific code
      // This is required prior to taking the screenshot (Android only).
      await binding.convertFlutterSurfaceToImage();
    } else if (Platform.isIOS) {
      // iOS-specific code
    }

    // Give extra time to settle to avoid spurrious screenshot issues
    const settleDuration = Duration(seconds: 3);

    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Timeline'));
    await tester.pump();
    await tester.pumpAndSettle(settleDuration);

    // Start filename with a number to put them in the correct order on the App Store
    await capture(binding, '5. timeline');

    await tester.tap(find.text(mealEntry2.mealElements[0].foodReference.name));
    await tester.pump();
    await tester.pumpAndSettle(settleDuration);

    await capture(binding, '6. meal');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bowel Movement'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(settleDuration);

    await capture(binding, '7. bowel_movement');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text(symptomEntry.symptom.symptomType.name));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(settleDuration);

    await capture(binding, '8. symptom');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pantry'));
    await tester.pump();
    await tester.pumpAndSettle(settleDuration);

    await capture(binding, '0. pantry');

    // Only use preferences for food page
    when(preferencesService.stream).thenAnswer((_) => BehaviorSubject<Preferences>()..add(preferences));
    when(preferencesService.value).thenReturn(preferences);
    await tester.tap(find.text(elementaryFood.name));
    await tester.pump();
    await tester.pumpAndSettle(settleDuration);
    when(preferencesService.stream).thenAnswer((_) => BehaviorSubject<Preferences>()..add(Preferences()));
    when(preferencesService.value).thenReturn(Preferences());

    await capture(binding, '1. sensitivity');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text(compoundFood.name));
    await tester.pump();
    await tester.pumpAndSettle(settleDuration);
    await tester.tap(find.text('Ingredients'));
    await tester.pump();
    await tester.pumpAndSettle(settleDuration);

    await capture(binding, '2. ingredients');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Foods'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text(foodGroupName));
    await tester.pump();
    await tester.pumpAndSettle(settleDuration);

    await capture(binding, '3. browse');

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analysis'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.drag(find.text('Pantry foods by irritant'), const Offset(0.0, -180.0));
    await tester.pumpAndSettle(settleDuration);

    await capture(binding, '4. analysis');
  });
}
