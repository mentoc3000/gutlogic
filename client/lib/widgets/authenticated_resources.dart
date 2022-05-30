import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../blocs/food_search/food_search_bloc.dart';
import '../blocs/recent_foods/recent_foods.dart';
import '../blocs/symptom_type/symptom_type_bloc.dart';
import '../blocs/user_cubit.dart';
import '../models/application_user.dart';
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
import '../resources/irritant_service.dart';
import '../resources/pantry_service.dart';
import '../resources/profile_repository.dart';
import '../resources/sensitivity/heuristic_sensitivity_prediction_service.dart';
import '../resources/sensitivity/sensitivity_repository.dart';
import '../resources/sensitivity/sensitivity_service.dart';
import '../resources/symptom_type_repository.dart';
import '../resources/user_food_details_repository.dart';
import '../resources/user_repository.dart';
import '../routes/routes.dart';
import '../util/app_config.dart';

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
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return SensitivityRepository(
              firestoreService: context.read<FirestoreService>(),
              crashlytics: context.read<CrashlyticsService>(),
            );
          }),
          RepositoryProvider(create: (context) {
            return IrritantService(firestoreService: context.read<FirestoreService>());
          }),
          RepositoryProvider(create: (context) {
            return FoodGroupsRepository(firestoreService: context.read<FirestoreService>());
          }),
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
            final edamamService = EdamamService(cloudFunctionService: context.read<CloudFunctionService>());
            final edamamFoodRepository = EdamamFoodRepository(edamamService: edamamService);
            final customFoodRepository = CustomFoodRepository(firestoreService: context.read<FirestoreService>());
            return FoodService(edamamFoodRepository: edamamFoodRepository, customFoodRepository: customFoodRepository);
          }),
        ],
        child: MultiBlocProvider(
          providers: const [
            // TODO move these into their most tightly nested widget trees
            BlocProvider(create: FoodSearchBloc.fromContext),
            BlocProvider(create: SymptomTypeBloc.fromContext),
            BlocProvider(create: RecentFoodsCubit.fromContext),
          ],
          child: ChangeNotifierProvider(
            create: (context) {
              // TODO move this into its most tightly nested widget tree
              final sensitivityRepository = context.read<SensitivityRepository>();
              final heuristicPredictionService = context.read<AppConfig>().isDevelopment
                  ? HeuristicSensitivityPredictionService(
                      irritantService: context.read<IrritantService>(),
                      sensitivityMapStream: sensitivityRepository.streamAll(),
                    )
                  : null;
              return SensitivityService(
                sensitivityRepository: sensitivityRepository,
                heuristicPredictionService: heuristicPredictionService,
              );
            },
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
