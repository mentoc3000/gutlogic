import 'dart:async';
import '../models/medicine.dart';
import '../resources/searchable_repository.dart';

class MedicineRepository implements SearchableRepository {

  final List<Medicine> allMedicines = [
    Medicine(name: 'Fiber'),
    Medicine(name: 'Probiotic'),
  ];

  MedicineRepository();

  Future<List<Medicine>> fetchAll() async {
    // await Future.delayed(Duration(seconds: 1));
    return allMedicines;
  }

  Future<List<Medicine>> fetchQuery(String query) async {
    if (query == '') {
      return fetchAll();
    }
    return allMedicines
        .where((f) => f.toString().contains(query))
        .toList();
  }
}
