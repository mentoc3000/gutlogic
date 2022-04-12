import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_reference/food_reference.dart';
import '../../resources/diary_repositories/diary_repository.dart';
import 'recent_foods_state.dart';

class RecentFoodsCubit extends Cubit<RecentFoodsState> {
  final DiaryRepository diaryRepository;

  RecentFoodsCubit({required this.diaryRepository}) : super(const RecentFoodsLoading()) {
    update();
  }

  static RecentFoodsCubit fromContext(BuildContext context) {
    return RecentFoodsCubit(diaryRepository: context.read<DiaryRepository>());
  }

  void update() {
    diaryRepository.recentFoods().then(onRepoValue, onError: onRepoError);
  }

  void onRepoValue(BuiltList<FoodReference> recentFoods) {
    emit(RecentFoodsLoaded(recentFoods));
  }

  void onRepoError(Object error, StackTrace trace) {
    emit(RecentFoodsError.fromError(error: error, trace: trace));
  }
}
