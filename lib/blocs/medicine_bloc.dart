import '../resources/medicine_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/medicine.dart';
import 'searchable_bloc.dart';

class MedicineBloc extends SearchableBloc<Medicine, MedicineRepository> {
  MedicineBloc() : super(MedicineRepository());
}
