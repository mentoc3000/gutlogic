import '../resources/medicine_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/medicine.dart';
import 'bloc_interfaces.dart';

class MedicineBloc extends SearchableBloc{

  MedicineBloc()
      : super(repository: MedicineRepository());

  Stream<List<Medicine>> get all => controller.stream.cast();

}
