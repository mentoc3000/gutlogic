import '../resources/diary_entry_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/diary_entry.dart';

class DiaryEntryBloc {
  final _repository = DiaryEntryRepository();

  // Use broadcast stream because stream in search gets subscribed to multiple times
  final _foodsController = StreamController<List<DiaryEntry>>.broadcast();

  Stream<List<DiaryEntry>> get allFoods => _foodsController.stream;

  void fetchAllDiaryEntries() async {
    List<DiaryEntry> foods = await _repository.fetchAllDiaryEntries();
    _foodsController.sink.add(foods);
  }

  void addEntry(DiaryEntry newEntry) => _repository.addEntry;

  void addEntries(List<DiaryEntry> newEntries) => _repository.addEntries;

  void removeEntry(DiaryEntry entry) => _repository.removeEntry;

  dispose() {
    _foodsController.close();
  }
}