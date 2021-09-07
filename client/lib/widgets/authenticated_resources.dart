import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/authentication/authentication.dart';
import '../blocs/food/food_bloc.dart';
import '../blocs/symptom_type/symptom_type_bloc.dart';
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
import '../resources/pantry_service.dart';
import '../resources/sensitivity/sensitivity_repository.dart';
import '../resources/sensitivity/sensitivity_service.dart';
import '../resources/symptom_type_repository.dart';
import '../resources/user_food_details_repository.dart';
import '../resources/user_repository.dart';
import '../routes/routes.dart';

class AuthenticatedResources extends StatelessWidget {
  final Widget child;
  final GlobalKey navigatorKey;

  AuthenticatedResources({required this.child, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc.fromContext(context),
      child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: listener,
        buildWhen: condition,
        builder: builder,
      ),
    );
  }

  bool condition(AuthenticationState prev, AuthenticationState next) {
    // Ignore transitions into the AuthenticationUnknown state.
    return (next is Authenticated || next is Unauthenticated);
  }

  Widget builder(BuildContext context, AuthenticationState state) {
    if (state is Authenticated) {
      // Wrap the child views in the global authenticated repositories/blocs.
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) {
            return FirestoreService(userID: context.read<UserRepository>().user!.id);
          }),
          RepositoryProvider(create: (context) {
            // TODO move this into its most tightly nested widget tree
            return SensitivityRepository(
              firestoreService: context.read<FirestoreService>(),
              crashlytics: context.read<CrashlyticsService>(),
            );
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
          providers: [
            // TODO move these into their most tightly nested widget trees
            BlocProvider(create: (context) => FoodBloc.fromContext(context)),
            BlocProvider(create: (context) => SymptomTypeBloc.fromContext(context)),
          ],
          child: ChangeNotifierProvider(
            create: (context) {
              // TODO move this into its most tightly nested widget tree
              return SensitivityService(
                sensitivityRepository: context.read<SensitivityRepository>(),
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

  void listener(BuildContext context, AuthenticationState state) {
    Route dest;

    if (state is Authenticated) {
      // Navigate to the verify email page if the user has not verified their email yet.
      final user = context.read<UserRepository>().user!;

      if (user.verified == false) {
        dest = Routes.of(context).verifyEmail(user.email);
      } else if (user.consented == false) {
        dest = Routes.of(context).consent;
      } else {
        dest = Routes.of(context).main;
      }
    } else if (state is Unauthenticated) {
      // Always navigate to the root page if the user is unauthenticated.
      dest = Routes.of(context).root;
    } else {
      return;
    }

    final navigatorContext = navigatorKey.currentContext;

    // TODO make sure we aren't navigating to the same page
    // When the authentication state changes, we replace the entire navigation stack.
    Navigator.of(navigatorContext!).pushAndRemoveUntil(dest, (route) => false);
  }
}
