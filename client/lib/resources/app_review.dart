import 'package:advanced_in_app_review/advanced_in_app_review.dart';

/// Call to begin monitoring when to request app review
///
/// Should be called only once.
void activateReviewManager() {
  AdvancedInAppReview()
      .setMinLaunchTimes(5)
      .setMinDaysAfterInstall(7)
      .setMinDaysBeforeRemind(7)
      .setMinSecondsBeforeShowDialog(2)
      .monitor();
}
