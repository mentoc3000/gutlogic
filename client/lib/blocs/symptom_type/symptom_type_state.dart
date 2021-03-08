import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';

import '../../models/symptom_type.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class SymptomTypeState extends Equatable {
  const SymptomTypeState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class SymptomTypesLoading extends SymptomTypeState with SearchableLoading {}

class SymptomTypesLoaded extends SymptomTypeState with SearchableLoaded {
  @override
  final BuiltList<SymptomType> items;

  SymptomTypesLoaded(this.items);
}

class SymptomTypeError extends SymptomTypeState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport report;

  SymptomTypeError({@required this.message}) : report = null;

  SymptomTypeError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
