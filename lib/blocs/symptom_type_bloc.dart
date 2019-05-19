import '../resources/symptom_type_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/symptom.dart';
import 'bloc_interfaces.dart';

class SymptomTypeBloc extends SearchableBloc{

  SymptomTypeBloc()
      : super(repository: SymptomTypeRepository());

  Stream<List<SymptomType>> get all => controller.stream.cast();

}
