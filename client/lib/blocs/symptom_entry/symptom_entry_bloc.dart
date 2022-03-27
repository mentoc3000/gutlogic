import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/diary_entry/symptom_entry.dart';
import '../../resources/diary_repositories/symptom_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'symptom_entry_event.dart';
import 'symptom_entry_state.dart';

class SymptomEntryBloc extends Bloc<SymptomEntryEvent, SymptomEntryState> with StreamSubscriber, DiaryEntryMapper {
  final SymptomEntryRepository repository;

  SymptomEntryBloc({required this.repository}) : super(SymptomEntryLoading()) {
    timelineRepository = repository;

    on<StreamSymptomEntry>(_onStream);
    on<LoadSymptomEntry>((event, emit) => emit(SymptomEntryLoaded(event.diaryEntry)));
    on<CreateFromAndStreamSymptomEntry>(_onCreateAndStream);
    on<UpdateSymptom>(_onUpdateSymptom, transformer: debounceTransformer);
    on<UpdateSymptomType>(_onUpdateType, transformer: debounceTransformer);
    on<UpdateSymptomName>(_onUpdateName, transformer: debounceTransformer);
    on<UpdateSeverity>(_onUpdateSeverity, transformer: debounceTransformer);
    on<UpdateSymptomEntry>(onUpdateEntry, transformer: debounceTransformer);
    on<UpdateSymptomEntryDateTime>(onUpdateDateTime, transformer: debounceTransformer);
    on<UpdateSymptomEntryNotes>(onUpdateNotes, transformer: debounceTransformer);
    on<DeleteSymptomEntry>(onDeleteEntry);
    on<ThrowSymptomEntryError>((event, emit) => emit(SymptomEntryError.fromReport(event.report)));
  }

  static SymptomEntryBloc fromContext(BuildContext context) {
    return SymptomEntryBloc(repository: context.read<SymptomEntryRepository>());
  }

  void _onStream(StreamSymptomEntry event, Emitter<SymptomEntryState> emit) {
    try {
      emit(SymptomEntryLoaded(event.diaryEntry));
      streamSubscription = timelineRepository.stream(event.diaryEntry).listen(
            (d) => add(LoadSymptomEntry(d as SymptomEntry)),
            onError: (error, StackTrace trace) => add(ThrowSymptomEntryError.fromError(error: error, trace: trace)),
          );
    } catch (error, trace) {
      emit(SymptomEntryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onCreateAndStream(CreateFromAndStreamSymptomEntry event, Emitter<SymptomEntryState> emit) async {
    try {
      final symptomEntry = await repository.createFrom(event.symptomType);
      if (symptomEntry != null) {
        add(StreamSymptomEntry(symptomEntry));
      } else {
        emit(SymptomEntryError(message: 'Failed to create symptom entry'));
      }
    } catch (error, trace) {
      emit(SymptomEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateSymptom(UpdateSymptom event, Emitter<SymptomEntryState> emit) {
    try {
      final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
      unawaited(repository.updateSymptom(diaryEntry, event.symptom));
    } catch (error, trace) {
      emit(SymptomEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateType(UpdateSymptomType event, Emitter<SymptomEntryState> emit) {
    try {
      final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
      unawaited(repository.updateSymptomType(diaryEntry, event.symptomType));
    } catch (error, trace) {
      emit(SymptomEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateName(UpdateSymptomName event, Emitter<SymptomEntryState> emit) {
    try {
      final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
      unawaited(repository.updateSymptomName(diaryEntry, event.symptomName));
    } catch (error, trace) {
      emit(SymptomEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateSeverity(UpdateSeverity event, Emitter<SymptomEntryState> emit) {
    try {
      final diaryEntry = (state as DiaryEntryLoaded).diaryEntry as SymptomEntry;
      unawaited(repository.updateSeverity(diaryEntry, event.severity));
    } catch (error, trace) {
      emit(SymptomEntryError.fromError(error: error, trace: trace));
    }
  }
}
