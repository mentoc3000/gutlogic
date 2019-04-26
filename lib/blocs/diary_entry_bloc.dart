import '../resources/diary_entry_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/diary_entry.dart';

class DiaryEntryBloc {
  final _repository = DiaryEntryRepository();

  // Use broadcast stream because stream in search gets subscribed to multiple times
  final _foodsController = StreamController<List<DiaryEntry>>.broadcast();

  Stream<List<DiaryEntry>> get allFoods => _foodsController.stream;

  fetchAllDiaryEntries() async {
    List<DiaryEntry> foods = await _repository.fetchAllDiaryEntries();
    _foodsController.sink.add(foods);
  }

  dispose() {
    _foodsController.close();
  }
}