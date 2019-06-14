import '../resources/symptom_type_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/symptom_type.dart';
import 'searchable_bloc.dart';

class SymptomTypeBloc
    extends SearchableBloc<SymptomType, SymptomTypeRepository> {
  SymptomTypeBloc() : super(SymptomTypeRepository());
}
