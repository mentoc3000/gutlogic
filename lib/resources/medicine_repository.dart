// import 'dart:async';
import '../models/medicine.dart';
import 'package:built_collection/built_collection.dart';
import 'searchable_repository.dart';

class MedicineRepository extends SearchableRepository<Medicine> {
  MedicineRepository() : super() {
    items = BuiltList([
      Medicine(name: 'Fiber'),
      Medicine(name: 'Probiotic'),
    ]);
  }
}
