import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:gutlogic/auth/auth_provider.dart';
import 'package:gutlogic/blocs/account/account.dart';
import 'package:gutlogic/blocs/authentication/authentication.dart';
import 'package:gutlogic/blocs/diary/diary.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/pages/main_tabs.dart';
import 'package:gutlogic/resources/diary_repositories/bowel_movement_entry_repository.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_entry_repository.dart';
import 'package:gutlogic/resources/diary_repositories/symptom_entry_repository.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:gutlogic/routes/routes.dart';
import 'package:gutlogic/style/gl_theme.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

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
  DiaryRepository,
  MealElementRepository,
  MealEntryRepository,
  PantryRepository,
  SymptomEntryRepository,
  UserRepository,
])
void main() {
  // Pass the screenshots data request handler to the driver extension. This is required by the screenshot driver.
  enableFlutterDriverExtension(handler: screenshots.handler);

  // Today
  initializeTimeZones();
  final location = getLocation('America/Detroit');
  setLocalLocation(location);
  final now = TZDateTime.now(location);

  TZDateTime todayAt(int hour, int minute) => TZDateTime(location, now.year, now.month, now.day, hour, minute);

  // Mock user repository
  final userRepository = MockUserRepository();
  final user = ApplicationUser(
    id: 'id',
    email: 'email',
    verified: true,
    consented: true,
    providers: [AuthProvider.password].build(),
  );
  when(userRepository.user).thenReturn(user);

  // Mock authentication bloc
  final authenticationBloc = MockAuthenticationBloc();
  when(authenticationBloc.state).thenReturn(const Authenticated());

  // Mock diary
  final diaryRepository = MockDiaryRepository();
  final diary = [
    MealEntry(
      id: 'meal1',
      datetime: todayAt(7, 21),
      mealElements: [
        MealElement(
          id: 'mealElement2',
          foodReference: CustomFoodReference(id: 'Oatmeal', name: 'Oatmeal'),
          quantity: Quantity.unweighed(amount: 1, unit: 'cup'),
        ),
        MealElement(
          id: 'mealElement3',
          foodReference: CustomFoodReference(id: 'banana', name: 'Banana'),
          quantity: Quantity.unweighed(amount: 1, unit: 'each'),
        ),
        MealElement(
          id: 'mealElement1',
          foodReference: CustomFoodReference(id: 'orange juice', name: 'Orange Juice'),
          quantity: Quantity.unweighed(amount: 6, unit: 'oz'),
        ),
      ].build(),
    ),
    BowelMovementEntry(
      id: 'bm1',
      datetime: todayAt(9, 47),
      bowelMovement: BowelMovement(volume: 3, type: 4),
      notes: 'notes',
    ),
    MealEntry(
        id: 'meal2',
        datetime: todayAt(12, 38),
        mealElements: [
          MealElement(
            id: 'mealElement4',
            foodReference: CustomFoodReference(id: 'bread', name: 'Italian Bread'),
            quantity: Quantity.unweighed(amount: 2, unit: 'slices'),
          ),
          MealElement(
            id: 'mealElement5',
            foodReference: CustomFoodReference(id: 'turkey', name: 'Sliced Turkey'),
            quantity: Quantity.unweighed(amount: 5, unit: 'slices'),
          ),
          MealElement(
            id: 'mealElement6',
            foodReference: CustomFoodReference(id: 'lettuce', name: 'Lettuce'),
            quantity: Quantity.unweighed(amount: 2, unit: 'leaves'),
          ),
          MealElement(
            id: 'mealElement7',
            foodReference: CustomFoodReference(id: 'milk shake', name: 'Milk Shake'),
            quantity: Quantity.unweighed(amount: 12, unit: 'oz'),
            notes: 'Chocolate',
          ),
        ].build(),
        notes: 'Quick stop for fast food.'),
    SymptomEntry(
      id: 'symptom1',
      datetime: todayAt(14, 3),
      symptom: Symptom(symptomType: SymptomType(id: 'symptomType1', name: 'Bloated'), severity: Severity.intense),
      notes: 'Feels like a reaction to the milk shake.',
    ),
  ].build();
  when(diaryRepository.streamAll()).thenAnswer((_) => Stream.fromIterable([diary]));

  // Mock meal entry
  final mealEntryRepository = MockMealEntryRepository();
  final mealEntry = diary.whereType<MealEntry>().last;
  when(mealEntryRepository.stream(any)).thenAnswer((_) => Stream.fromIterable([mealEntry]));

  // Mock mealElement
  final mealElementRepository = MockMealElementRepository();
  when(mealElementRepository.stream(any)).thenAnswer((_) => Stream.fromIterable([mealEntry.mealElements.last]));

  // Mock bowel movement entry
  final bowelMovementEntryRepository = MockBowelMovementEntryRepository();
  final bowelMovementEntry = diary.whereType<BowelMovementEntry>().first;
  when(bowelMovementEntryRepository.stream(any)).thenAnswer((_) => Stream.fromIterable([bowelMovementEntry]));

  // Mock symptom entry
  final symptomEntryRepository = MockSymptomEntryRepository();
  final symptomEntry = diary.whereType<SymptomEntry>().first;
  when(symptomEntryRepository.stream(any)).thenAnswer((_) => Stream.fromIterable([symptomEntry]));

  // Mock pantry
  final pantryRepository = MockPantryRepository();
  final pantryEntries = [
    PantryEntry(id: '2', foodReference: CustomFoodReference(id: '2', name: 'Pasta'), sensitivity: Sensitivity.severe),
    PantryEntry(
      id: '1',
      foodReference: CustomFoodReference(id: '1', name: 'Wheat Bread'),
      sensitivity: Sensitivity.moderate,
      notes: 'Makes me feel bloated the rest of the day.',
    ),
    PantryEntry(id: '5', foodReference: CustomFoodReference(id: '5', name: 'Pear'), sensitivity: Sensitivity.mild),
    PantryEntry(id: '6', foodReference: CustomFoodReference(id: '6', name: 'Cola'), sensitivity: Sensitivity.mild),
    PantryEntry(id: '4', foodReference: CustomFoodReference(id: '4', name: 'Onion'), sensitivity: Sensitivity.none),
    PantryEntry(id: '3', foodReference: CustomFoodReference(id: '3', name: 'Garlic'), sensitivity: Sensitivity.none),
  ].build();
  when(pantryRepository.streamAll()).thenAnswer((_) => Stream.fromIterable([pantryEntries]));
  when(pantryRepository.stream(any)).thenAnswer((_) => Stream.fromIterable([pantryEntries.first]));

  // remove debug banner for screenshots
  WidgetsApp.debugAllowBannerOverride = false;

  final app = MultiRepositoryProvider(
    providers: [
      Routes.provider(),
      RepositoryProvider<BowelMovementEntryRepository>(create: (context) => bowelMovementEntryRepository),
      RepositoryProvider<DiaryRepository>(create: (context) => diaryRepository),
      RepositoryProvider<MealElementRepository>(create: (context) => mealElementRepository),
      RepositoryProvider<MealEntryRepository>(create: (context) => mealEntryRepository),
      RepositoryProvider<PantryRepository>(create: (context) => pantryRepository),
      RepositoryProvider<SymptomEntryRepository>(create: (context) => symptomEntryRepository),
      RepositoryProvider<UserRepository>(create: (context) => userRepository),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AccountBloc(userRepository: context.read<UserRepository>())),
        BlocProvider<AuthenticationBloc>(create: (context) => authenticationBloc),
        BlocProvider(create: (context) => DiaryBloc(repository: context.read<DiaryRepository>())),
        BlocProvider(create: (context) => PantryBloc(repository: context.read<PantryRepository>())),
      ],
      child: MainTabsPageWrapper(),
    ),
  );

  runApp(app);
}
