import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';

import '../../models/food/custom_food.dart';
import '../../models/food/edamam_food.dart';
import '../../models/food/food.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class FoodsLoading extends FoodState with SearchableLoading {}

class FoodsLoaded extends FoodState with SearchableLoaded {
  @override
  BuiltList<Food> get items => <Food>[...customFoods, ...edamamFoods].build();

  final BuiltList<CustomFood> customFoods;
  final BuiltList<EdamamFood> edamamFoods;

  FoodsLoaded({@required this.edamamFoods, @required this.customFoods});
}

class FoodError extends FoodState with SearchableError, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport report;

  FoodError({@required this.message}) : report = null;

  FoodError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
