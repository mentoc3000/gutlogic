import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/diary_repositories/diary_repository.dart';
import 'foods_suggestion_cubit.dart';

class RecentFoodsCubit extends FoodSuggestionCubit {
  final DiaryRepository diaryRepository;

  RecentFoodsCubit({required this.diaryRepository}) : super(foodsGetter: diaryRepository.recentFoods) {
    update();
  }

  static RecentFoodsCubit fromContext(BuildContext context) {
    return RecentFoodsCubit(diaryRepository: context.read<DiaryRepository>());
  }
}
