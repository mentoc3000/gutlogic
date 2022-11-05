import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/diary_entry/bowel_movement_entry.dart';
import '../models/diary_entry/meal_entry.dart';
import '../models/diary_entry/symptom_entry.dart';
import '../models/food/ingredient.dart';
import '../models/food_reference/food_reference.dart';
import '../models/meal_element.dart';
import '../models/pantry/pantry_entry.dart';
import '../models/symptom_type.dart';
import '../pages/account/account_page.dart';
import '../pages/account_create/account_create_page.dart';
import '../pages/account_delete/account_delete_page.dart';
import '../pages/bowel_movement_entry/bowel_movement_entry_page.dart';
import '../pages/consent/consent_page.dart';
import '../pages/food/food_page.dart';
import '../pages/food_group/food_group_page.dart';
import '../pages/ingredients/ingredients_page.dart';
import '../pages/landing/landing_page.dart';
import '../pages/login/login_page.dart';
import '../pages/main_tabs.dart';
import '../pages/meal_element_entry/meal_element_entry_page.dart';
import '../pages/meal_entry/meal_entry_page.dart';
import '../pages/pantry_entry/pantry_entry_page.dart';
import '../pages/prior_foods/prior_foods_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/reauthenticate/reauthenticate_page.dart';
import '../pages/register/register_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/similar_foods/similar_foods_page.dart';
import '../pages/subscribe/subscribe_page.dart';
import '../pages/symptom_entry/symptom_entry_page.dart';

class Routes {
  /// Find a provided Routes in the widget tree.
  static Routes of(BuildContext context) {
    return RepositoryProvider.of<Routes>(context);
  }

  Route<Widget> get root {
    return MaterialPageRoute(
      builder: (context) => LandingPage.provisioned(),
      settings: const RouteSettings(name: 'Landing Page'),
    );
  }

  Route<Widget> get login {
    return MaterialPageRoute(
      builder: (context) => LoginPage.provisioned(),
      settings: const RouteSettings(name: 'Login Page'),
    );
  }

  Route<Widget> get register {
    return MaterialPageRoute(
      builder: (context) => RegisterPage.provisioned(),
      settings: const RouteSettings(name: 'Register Page'),
    );
  }

  Route<Widget> get consent {
    return MaterialPageRoute(
      builder: (context) => ConsentPage.provisioned(),
      settings: const RouteSettings(name: 'Verify Age Page'),
    );
  }

  Route<Widget> get main {
    return MaterialPageRoute(
      builder: MainTabs.provisioned,
      settings: const RouteSettings(name: 'Main Page'),
    );
  }

  Route<Widget> get settings {
    return MaterialPageRoute(
      builder: (context) => SettingsPage(),
      settings: const RouteSettings(name: 'Settings Page'),
    );
  }

  Route<Widget> get account {
    return MaterialPageRoute(
      builder: (context) => AccountPage(),
      settings: const RouteSettings(name: 'Account Page'),
    );
  }

  Route<Widget> get createAccount {
    return MaterialPageRoute(
      builder: (context) => AccountCreatePage.provisioned(),
      settings: const RouteSettings(name: 'Create Account Page'),
    );
  }

  Route<Widget> get deleteAccount {
    return MaterialPageRoute(
      builder: (context) => AccountDeletePage.provisioned(),
      settings: const RouteSettings(name: 'Delete Account Page'),
    );
  }

  Route<Widget> get reauthenticate {
    return MaterialPageRoute(
      builder: (context) => ReauthenticatePage.provisioned(),
      settings: const RouteSettings(name: 'Reauthenticate Page'),
    );
  }

  Route<Widget> get profile {
    return MaterialPageRoute(
      builder: (context) => ProfilePage(),
      settings: const RouteSettings(name: 'Profile Page'),
    );
  }

  Route<Widget> createSubscribeRoute({VoidCallback? onSubscribed}) {
    return MaterialPageRoute(
      builder: (context) => SubscribePage(onSubscribed: onSubscribed),
      settings: const RouteSettings(name: 'Subscribe Page'),
      fullscreenDialog: true,
    );
  }

  Route<Widget> createMealEntryRoute({MealEntry? entry}) {
    if (entry == null) {
      return MaterialPageRoute(
        builder: (context) => MealEntryPage.forNewEntry(),
        settings: const RouteSettings(name: 'New Meal Entry Page'),
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => MealEntryPage.forExistingEntry(entry),
        settings: const RouteSettings(name: 'Meal Entry Page'),
      );
    }
  }

  Route<Widget> createSymptomEntryRoute({required SymptomEntry entry}) {
    return MaterialPageRoute(
      builder: (context) => SymptomEntryPage.forExistingEntry(entry),
      settings: const RouteSettings(name: 'Symptom Entry Page'),
    );
  }

  Route<Widget> createSymptomEntryRouteFrom({required SymptomType symptomType}) {
    return MaterialPageRoute(builder: (context) => SymptomEntryPage.forNewEntryFrom(symptomType));
  }

  Route<Widget> createBowelMovementEntryRoute({BowelMovementEntry? entry}) {
    if (entry == null) {
      return MaterialPageRoute(
        builder: (context) => BowelMovementEntryPage.forNewEntry(),
        settings: const RouteSettings(name: 'New Bowel Movement Entry Page'),
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => BowelMovementEntryPage.forExistingEntry(entry),
        settings: const RouteSettings(name: 'Bowel Movement Entry Page'),
      );
    }
  }

  Route<Widget> createMealElementPageRoute({required MealElement mealElement}) {
    return MaterialPageRoute(
      builder: (context) => MealElementEntryPage.forMealElement(mealElement),
      settings: const RouteSettings(name: 'MealElement Entry Page'),
    );
  }

  Route<Widget> createPantryEntryPageRoute({required PantryEntry pantryEntry}) {
    return MaterialPageRoute(builder: (context) => PantryEntryPage.forPantryEntry(pantryEntry));
  }

  Route<Widget> createPantryEntryPageRouteForFood(FoodReference foodReference) {
    return MaterialPageRoute(builder: (context) => PantryEntryPage.forFood(foodReference));
  }

  Route<Widget> createFoodPageRoute(FoodReference foodReference) {
    return MaterialPageRoute(builder: (context) => FoodPage.forFood(foodReference));
  }

  Route<Widget> createFoodGroupRoute({required String name}) {
    return MaterialPageRoute(builder: (context) => FoodGroupPage(group: name));
  }

  Route<Widget> createPriorFoodsPageRoute({required DateTime priorTo}) {
    return MaterialPageRoute(builder: (conext) => PriorFoodsPage.provisioned(priorTo: priorTo));
  }

  Route<Widget> createSimilarFoodsRoute({required FoodReference food}) {
    return MaterialPageRoute(builder: (context) => SimilarFoodsPage(food: food));
  }

  Route<Widget> createIngredientsPageRoute({required BuiltList<Ingredient> ingredients}) {
    return MaterialPageRoute(builder: (context) => IngredientsPage(ingredients: ingredients));
  }
}
