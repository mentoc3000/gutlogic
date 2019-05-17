import '../resources/symptom_type_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/symptom.dart';

class SymptomTypeBloc {
  // final AppSyncService appSyncService;
  final SymptomTypeRepository symptomTypeRepository = SymptomTypeRepository();

  // Use broadcast stream because stream in search gets subscribed to multiple times
  final _symptomTypeController = StreamController<List<SymptomType>>.broadcast();

  Stream<List<SymptomType>> get all => _symptomTypeController.stream;

  fetchAll() async {
    List<SymptomType> foods = await symptomTypeRepository.fetchAll();
    _symptomTypeController.sink.add(foods);
  }

  fetchQuery(String query) async {
    List<SymptomType> foods = await symptomTypeRepository.fetchQuery(query);
    _symptomTypeController.sink.add(foods);
  }

  dispose() {
    _symptomTypeController.close();
  }
}
