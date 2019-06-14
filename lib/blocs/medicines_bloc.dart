import 'dart:async';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:bloc/bloc.dart';
import '../resources/medicine_repository.dart';
import 'medicines_event.dart';
import 'medicines_state.dart';
import '../models/medicine.dart';

class MedicinesBloc extends Bloc<MedicinesEvent, MedicinesState> {

  final MedicineRepository medicineRepository;

  MedicinesBloc({@required this.medicineRepository});

  // @override
  // Stream<MedicinesState> transform(
  //   Stream<MedicinesEvent> events,
  //   Stream<MedicinesState> Function(MedicinesEvent event) next,
  // ) {
  //   return super.transform(
  //     (events as Observable<MedicinesEvent>).debounceTime(
  //       Duration(milliseconds: 500),
  //     ),
  //     next,
  //   );
  // }

  @override
  MedicinesState get initialState => MedicinesUninitialized();

  @override
  Stream<MedicinesState> mapEventToState(
    MedicinesEvent event,
  ) async* {
    if (event is Fetch) {
      try {
        BuiltList<Medicine> medicines = await medicineRepository.fetchAll();
        yield MedicinesLoaded(medicines: medicines);
      } catch (_) {
        yield MedicinesError();
      }
    }
  }
}
