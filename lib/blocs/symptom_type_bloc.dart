import '../resources/symptom_type_repository.dart';
import '../models/symptom_type.dart';
import 'searchable_bloc.dart';

class SymptomTypeBloc
    extends SearchableBloc<SymptomType, SymptomTypeRepository> {
  SymptomTypeBloc(SymptomTypeRepository symptomTypeRepository)
      : super(symptomTypeRepository);
}
