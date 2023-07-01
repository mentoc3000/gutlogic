import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_reference/food_reference.dart';
import '../../resources/diary_repositories/diary_repository.dart';
import 'recent_foods_state.dart';

class RecentFoodsCubit extends Cubit<RecentFoodsState> {
  final DateTime? start;
  final DateTime? end;
  final DiaryRepository diaryRepository;

  RecentFoodsCubit({required this.diaryRepository, this.start, this.end}) : super(const RecentFoodsLoading()) {
    update();
  }

  static RecentFoodsCubit fromContext(BuildContext context, {DateTime? start, DateTime? end}) {
    return RecentFoodsCubit(diaryRepository: context.read<DiaryRepository>(), start: start, end: end);
  }

  void update() {
    diaryRepository.recentFoods(start: start, end: end).then(onRepoValue, onError: onRepoError);
  }

  void onRepoValue(BuiltList<FoodReference> recentFoods) {
    if (!isClosed) {
      emit(RecentFoodsLoaded(recentFoods));
    }
  }

  void onRepoError(Object error, StackTrace trace) {
    if (!isClosed) {
      emit(RecentFoodsError.fromError(error: error, trace: trace));
    }
  }
}
