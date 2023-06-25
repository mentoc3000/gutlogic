import 'package:built_collection/built_collection.dart';

import '../../models/preferences/preferences.dart';
import '../bloc_helpers.dart';

class PreferencesState extends BaseState {
  const PreferencesState();

  @override
  List<Object?> get props => [];
}

class PreferencesLoading extends PreferencesState {
  const PreferencesLoading();
}

class PreferencesLoaded extends PreferencesState {
  final Preferences preferences;
  final BuiltList<String> irritants;

  const PreferencesLoaded({required this.preferences, required this.irritants});

  @override
  List<Object?> get props => [preferences, irritants];
}

class PreferencesFailure extends PreferencesState with ErrorState {
  @override
  final String? message;

  PreferencesFailure({this.message});

  @override
  List<Object?> get props => [message];
}
