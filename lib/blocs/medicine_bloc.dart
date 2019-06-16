import '../resources/medicine_repository.dart';
import '../models/medicine.dart';
import 'searchable_bloc.dart';

class MedicineBloc extends SearchableBloc<Medicine, MedicineRepository> {
  MedicineBloc(MedicineRepository medicineRepository)
      : super(medicineRepository);
}
