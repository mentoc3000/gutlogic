import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/diary_entry/bowel_movement_entry.dart';
import '../models/diary_entry/meal_entry.dart';
import '../models/diary_entry/symptom_entry.dart';
import '../models/food/food.dart';
import '../models/meal_element.dart';
import '../models/symptom_type.dart';
import '../pages/account/account_page.dart';
import '../pages/bowel_movement_entry/bowel_movement_entry_page.dart';
import '../pages/change_password/change_password_page.dart';
import '../pages/consent/consent_page.dart';
import '../pages/food/food_page.dart';
import '../pages/landing/landing_page.dart';
import '../pages/login/login_page.dart';
import '../pages/main_tabs.dart';
import '../pages/meal_element_entry/meal_element_entry_page.dart';
import '../pages/meal_entry/meal_entry_page.dart';
import '../pages/register/register_page.dart';
import '../pages/reset_password/reset_password_page.dart';
import '../pages/symptom_entry/symptom_entry_page.dart';
import '../pages/verify_email/verify_email_page.dart';

class Routes {
  /// Find a provided Routes in the widget tree.
  static Routes of(BuildContext context) => Provider.of<Routes>(context, listen: false);

  /// Create a new Provider widget for the Routes.
  static Provider<Routes> provider() => Provider<Routes>(create: (_) => Routes());

  Route get root {
    return MaterialPageRoute(
      builder: (context) => LandingPage.provisioned(),
      settings: const RouteSettings(name: 'Landing Page'),
    );
  }

  Route get login {
    return MaterialPageRoute(
      builder: (context) => LoginPage.provisioned(),
      settings: const RouteSettings(name: 'Login Page'),
    );
  }

  Route get resetPassword {
    return MaterialPageRoute(
      builder: (context) => ResetPasswordPage.provisioned(),
      settings: const RouteSettings(name: 'Reset Password Page'),
    );
  }

  Route get register {
    return MaterialPageRoute(
      builder: (context) => RegisterPage.provisioned(),
      settings: const RouteSettings(name: 'Register Page'),
    );
  }

  Route get consent {
    return MaterialPageRoute(
      builder: (context) => ConsentPage.provisioned(),
      settings: const RouteSettings(name: 'Verify Age Page'),
    );
  }

  Route verifyEmail(String email) {
    return MaterialPageRoute(
      builder: (context) => VerifyEmailPage.provisioned(email: email),
      settings: const RouteSettings(name: 'Verify Email Page'),
    );
  }

  Route get main {
    return MaterialPageRoute(
      builder: MainTabs.provisioned,
      settings: const RouteSettings(name: 'Main Page'),
    );
  }

  Route get account {
    return MaterialPageRoute(
      builder: (context) => AccountPage.provisioned(),
      settings: const RouteSettings(name: 'Account Page'),
    );
  }

  Route get changePassword {
    return MaterialPageRoute(
      builder: (context) => ChangePasswordPage.provisioned(),
      settings: const RouteSettings(name: 'Change Password Page'),
    );
  }

  Route createFoodPageRoute({@required Food food}) {
    return MaterialPageRoute(
      builder: (context) => FoodPage(food: food),
      settings: const RouteSettings(name: 'Food Page'),
    );
  }

  Route createMealEntryRoute({MealEntry entry}) {
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

  Route createSymptomEntryRoute({SymptomEntry entry}) {
    return MaterialPageRoute(
      builder: (context) => SymptomEntryPage.forExistingEntry(entry),
      settings: const RouteSettings(name: 'Symptom Entry Page'),
    );
  }

  Route createSymptomEntryRouteFrom({SymptomType symptomType}) {
    return MaterialPageRoute(builder: (context) => SymptomEntryPage.forNewEntryFrom(symptomType));
  }

  Route createBowelMovementEntryRoute({BowelMovementEntry entry}) {
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

  Route createMealElementPageRoute({@required MealElement mealElement}) {
    return MaterialPageRoute(
      builder: (context) => MealElementEntryPage.forMealElement(mealElement),
      settings: const RouteSettings(name: 'MealElement Entry Page'),
    );
  }
}
