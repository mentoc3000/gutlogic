// import 'dart:async';
import '../models/medicine.dart';
import 'package:built_collection/built_collection.dart';
import 'repository_interfaces.dart';

class MedicineRepository extends DatabaseRepository<Medicine> {
  MedicineRepository() : super() {
    items = BuiltList([
      Medicine(name: 'Fiber'),
      Medicine(name: 'Probiotic'),
    ]);
  }
}
