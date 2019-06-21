import 'dart:async';
import 'package:built_collection/src/list.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:gut_ai/models/symptom_type.dart';
import 'package:gut_ai/resources/symptom_type_repository.dart';
import 'package:gut_ai/blocs/symptom_type_bloc.dart';
import 'package:gut_ai/blocs/searchable_event.dart';
import 'package:gut_ai/blocs/searchable_state.dart';

void main() {
  group('SymptomType Bloc', () {
    SymptomTypeBloc symptomTypeBloc;
    MockSymptomTypeRepository symptomTypeRepository;
    SymptomType _constipation = SymptomType(name: 'Constipation');
    SymptomType _gas = SymptomType(name: 'Gas');
    BuiltList<SymptomType> _allSymptomTypes = BuiltList([_constipation, _gas]);
    BuiltList<SymptomType> _justGas = BuiltList([_gas]);

    setUp(() {
      symptomTypeRepository = MockSymptomTypeRepository();
      when(symptomTypeRepository.fetchAll())
          .thenAnswer((i) => Future.value(_allSymptomTypes));
      when(symptomTypeRepository.fetchQuery('Water'))
          .thenAnswer((i) => Future.value(_justGas));
      symptomTypeBloc = SymptomTypeBloc(symptomTypeRepository);
    });

    test('initial state is Loading', () {
      expect(symptomTypeBloc.initialState, SearchableLoading());
    });

    test('fetches all symptomTypes', () {
      final List<SearchableState> expected = [
        SearchableLoading(),
        SearchableLoaded<SymptomType>(_allSymptomTypes)
      ];

      expectLater(symptomTypeBloc.state, emitsInOrder(expected));

      symptomTypeBloc.dispatch(FetchAll());
    });

    test('fetches queried symptomTypes', () {
      final List<SearchableState> expected = [
        SearchableLoading(),
        SearchableLoaded<SymptomType>(_justGas)
      ];

      expectLater(symptomTypeBloc.state, emitsInOrder(expected));

      symptomTypeBloc.dispatch(FetchQuery('Water'));
    });
  });
}

class MockSymptomTypeRepository extends Mock implements SymptomTypeRepository {}
