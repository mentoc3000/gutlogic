import 'dart:async';
import '../models/model_interfaces.dart';
import '../resources/app_sync_service.dart';

abstract class GutAiBloc {

}

abstract class SearchableBloc extends GutAiBloc {
  Stream<List<Searchable>> get all;
  SearchableBloc(AppSyncService appSyncService);
  void fetchAll();
  void fetchQuery(String query);
}