// import 'dart:async';
import '../models/medicine.dart';
import 'package:built_collection/built_collection.dart';
import '../resources/database_repository.dart';

class MedicineRepository extends DatabaseRepository {
  MedicineRepository() : super() {
    items = BuiltList([
      Medicine(name: 'Fiber'),
      Medicine(name: 'Probiotic'),
    ]);
  }
}
