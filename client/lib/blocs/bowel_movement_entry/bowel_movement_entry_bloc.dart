import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../resources/diary_repositories/bowel_movement_entry_repository.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';
import 'bowel_movement_entry_event.dart';
import 'bowel_movement_entry_state.dart';

class BowelMovementEntryBloc extends Bloc<BowelMovementEntryEvent, BowelMovementEntryState>
    with StreamSubscriber, DiaryEntryMapper {
  final BowelMovementEntryRepository repository;

  BowelMovementEntryBloc({required this.repository}) : super(BowelMovementEntryLoading()) {
    timelineRepository = repository;

    on<StreamBowelMovementEntry>(_onStreamBowelMovementEntryEvent);
    on<LoadBowelMovementEntry>((event, emit) => emit(BowelMovementEntryLoaded(event.diaryEntry)));
    on<CreateAndStreamBowelMovementEntry>(_onCreateAndStream);
    on<UpdateType>(_onUpdateType, transformer: debounceTransformer);
    on<UpdateVolume>(_onUpdateVolume, transformer: debounceTransformer);
    on<UpdateBowelMovementEntry>(onUpdateEntry, transformer: debounceTransformer);
    on<UpdateBowelMovementEntryDateTime>(onUpdateDateTime, transformer: debounceTransformer);
    on<UpdateBowelMovementEntryNotes>(onUpdateNotes, transformer: debounceTransformer);
    on<DeleteBowelMovementEntry>(onDeleteEntry);
    on<ThrowBowelMovementEntryError>((event, emit) => emit(BowelMovementEntryError.fromReport(event.report)));
  }

  static BowelMovementEntryBloc fromContext(BuildContext context) {
    return BowelMovementEntryBloc(repository: context.read<BowelMovementEntryRepository>());
  }

  void _onStreamBowelMovementEntryEvent(StreamBowelMovementEntry event, Emitter<BowelMovementEntryState> emit) {
    try {
      emit(BowelMovementEntryLoaded(event.diaryEntry));

      streamSubscription = timelineRepository.stream(event.diaryEntry).listen(
        (d) {
          add(LoadBowelMovementEntry(d as BowelMovementEntry));
        },
        onError: (e, StackTrace t) {
          add(ThrowBowelMovementEntryError.fromError(error: e, trace: t));
        },
      );
    } catch (error, trace) {
      emit(BowelMovementEntryError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onCreateAndStream(CreateAndStreamDiaryEntry event, Emitter<BowelMovementEntryState> emit) async {
    try {
      final bowelMovementEntry = await repository.create();
      if (bowelMovementEntry != null) {
        add(StreamBowelMovementEntry(bowelMovementEntry));
      } else {
        emit(BowelMovementEntryError(message: 'Failed to create bowel movement entry'));
      }
    } catch (error, trace) {
      emit(BowelMovementEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateType(UpdateType event, Emitter<BowelMovementEntryState> emit) {
    try {
      final bowelMovementEntry = (state as DiaryEntryLoaded).diaryEntry as BowelMovementEntry;
      unawaited(repository.updateType(bowelMovementEntry, event.type));
    } catch (error, trace) {
      emit(BowelMovementEntryError.fromError(error: error, trace: trace));
    }
  }

  void _onUpdateVolume(UpdateVolume event, Emitter<BowelMovementEntryState> emit) {
    try {
      final bowelMovementEntry = (state as DiaryEntryLoaded).diaryEntry as BowelMovementEntry;
      unawaited(repository.updateVolume(bowelMovementEntry, event.volume));
    } catch (error, trace) {
      emit(BowelMovementEntryError.fromError(error: error, trace: trace));
    }
  }
}
