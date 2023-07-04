import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../blocs/food_group_search/food_group_search.dart';
import '../blocs/food_search/food_search_bloc.dart';
import '../blocs/subscription/subscription.dart';
import '../blocs/symptom_type/symptom_type_bloc.dart';
import '../blocs/user_cubit.dart';
import '../models/user/application_user.dart';
import '../resources/analysis_service.dart';
import '../resources/api_service.dart';
import '../resources/cached_api_service.dart';
import '../resources/diary_repositories/bowel_movement_entry_repository.dart';
import '../resources/diary_repositories/diary_repository.dart';
import '../resources/diary_repositories/meal_element_repository.dart';
import '../resources/diary_repositories/meal_entry_repository.dart';
import '../resources/diary_repositories/symptom_entry_repository.dart';
import '../resources/firebase/cloud_function_service.dart';
import '../resources/firebase/crashlytics_service.dart';
import '../resources/firebase/firestore_service.dart';
import '../resources/food/custom_food_repository.dart';
import '../resources/food/edamam_food_repository.dart';
import '../resources/food/edamam_service.dart';
import '../resources/food/food_service.dart';
import '../resources/food_group_repository.dart';
import '../resources/iap_service.dart';
import '../resources/irritant_service.dart';
import '../resources/local_storage.dart';
import '../resources/pantry_service.dart';
import '../resources/preferences_service.dart';
import '../resources/profile_repository.dart';
import '../resources/sensitivity/sensitivity_repository.dart';
import '../resources/sensitivity/sensitivity_service.dart';
import '../resources/symptom_type_repository.dart';
import '../resources/user_food_details_repository.dart';
import '../resources/user_repository.dart';
import '../routes/routes.dart';

class AuthenticatedResources extends StatelessWidget {
  final Widget child;
  final GlobalKey navigatorKey;

  const AuthenticatedResources({required this.child, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, ApplicationUser?>(
      listener: listener,
      listenWhen: condition,
      builder: builder,
      buildWhen: condition,
    );
  }

  bool condition(ApplicationUser? prev, ApplicationUser? next) {
    return (prev == null && next != null) || (prev != null && next == null);
  }

  Widget builder(BuildContext context, ApplicationUser? user) {
    if (user is ApplicationUser) {
      // Wrap the child views in the global authenticated repositories/blocs.
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) {
            return FirestoreService(userID: context.read<UserRepository>().user!.id);
          }),
          RepositoryProvider(create: (context) {
            return ProfileRepository(firestore: context.read<FirestoreService>());
          }),
          RepositoryProvider(create: (context) => CloudFunctionService()),
          RepositoryProvider(create: ApiService.fromContext),
          RepositoryProvider(create: CachedApiService.fromContext),
          RepositoryProvider(create: IapService.fromContext),
          RepositoryProvider(create: PreferencesService.fromContext),
          RepositoryProvider(create: (context) {
            // TODO: move this into its most tightly nested widget tree
            return SensitivityRepository(
              firestoreService: context.read<FirestoreService>(),
              crashlytics: context.read<CrashlyticsService>(),
            );
          }),
          RepositoryProvider(create: IrritantService.fromContext),
          RepositoryProvider(create: FoodGroupsRepository.fromContext),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return UserFoodDetailsRepository(
              firestoreService: context.read<FirestoreService>(),
              crashlytics: context.read<CrashlyticsService>(),
            );
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return BowelMovementEntryRepository(firestoreService: context.read<FirestoreService>());
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return DiaryRepository(
              firestoreService: context.read<FirestoreService>(),
              crashlytics: context.read<CrashlyticsService>(),
            );
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return PantryService(
              sensitivityRepository: context.read<SensitivityRepository>(),
              userFoodDetailsRepository: context.read<UserFoodDetailsRepository>(),
            );
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return MealElementRepository(
              firestoreService: context.read<FirestoreService>(),
              pantryService: context.read<PantryService>(),
            );
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return MealEntryRepository(
              firestoreService: context.read<FirestoreService>(),
              mealElementRepository: context.read<MealElementRepository>(),
            );
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return SymptomEntryRepository(firestoreService: context.read<FirestoreService>());
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return SymptomTypeRepository();
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            final edamamFoodRepository = EdamamFoodRepository(
              edamamService: EdamamService(apiService: context.read<ApiService>()),
              localStorage: context.read<LocalStorage>(),
              irritantService: context.read<IrritantService>(),
            );
            final customFoodRepository = CustomFoodRepository(firestoreService: context.read<FirestoreService>());
            return FoodService(edamamFoodRepository: edamamFoodRepository, customFoodRepository: customFoodRepository);
          }),
          RepositoryProvider(create: (context) {
            return AnalysisService(
              diaryRepository: context.read<DiaryRepository>(),
              pantryService: context.read<PantryService>(),
              irritantService: context.read<IrritantService>(),
            );
          })
        ],
        child: MultiBlocProvider(
          providers: const [
            // TODO move these into their most tightly nested widget trees
            BlocProvider(create: SubscriptionCubit.fromContext, lazy: false),
            BlocProvider(create: FoodSearchBloc.fromContext),
            BlocProvider(create: SymptomTypeBloc.fromContext),
            BlocProvider(create: FoodGroupSearchCubit.fromContext),
          ],
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: SensitivityService.fromContext),
            ],
            child: child,
          ),
        ),
      );
    } else {
      return child;
    }
  }

  void listener(BuildContext context, ApplicationUser? user) {
    Route<Widget> dest;

    if (user is ApplicationUser) {
      dest = user.consented ? Routes.of(context).main : Routes.of(context).consent;
    } else {
      AuthService.deauthenticate(context);
      dest = Routes.of(context).root;
    }

    final navigatorContext = navigatorKey.currentContext;

    // TODO make sure we aren't navigating to the same page
    // When the authentication state changes, we replace the entire navigation stack.
    Navigator.of(navigatorContext!).pushAndRemoveUntil(dest, (route) => false);
  }
}
