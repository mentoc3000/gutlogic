import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/symptom_type/symptom_type.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/symptom_type_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';

void main() {
  group('SymptomType Bloc', () {
    MockSymptomTypeRepository symptomTypeRepository;
    final constipation = SymptomType(id: 'symptomType1', name: 'Constipation');
    final gas = SymptomType(id: 'symptomType1', name: 'Gas');
    final allSymptomTypes = BuiltList<SymptomType>([constipation, gas]);
    final justGas = BuiltList<SymptomType>([gas]);

    setUp(() {
      symptomTypeRepository = MockSymptomTypeRepository();
      when(symptomTypeRepository.fetchAll()).thenAnswer((_) => Future<BuiltList<SymptomType>>.value(allSymptomTypes));
      when(symptomTypeRepository.fetchQuery(''))
          .thenAnswer((i) => Future<BuiltList<SymptomType>>.value(allSymptomTypes));
      when(symptomTypeRepository.streamQuery('')).thenAnswer((_) => Stream.value(allSymptomTypes));
      when(symptomTypeRepository.fetchQuery('Gas')).thenAnswer((_) => Future<BuiltList<SymptomType>>.value(justGas));
      when(symptomTypeRepository.streamQuery('Gas')).thenAnswer((_) => Stream.value(justGas));
    });

    blocTest(
      'initial state is Loading',
      build: () async => SymptomTypeBloc(repository: symptomTypeRepository),
      skip: 0,
      expect: [SymptomTypesLoading()],
    );

    blocTest(
      'fetches all symptom types',
      build: () async => SymptomTypeBloc(repository: symptomTypeRepository),
      act: (bloc) async => bloc.add(const FetchAllSymptomTypes()),
      expect: [SymptomTypesLoaded(allSymptomTypes)],
      verify: (bloc) async => verify(symptomTypeRepository.fetchQuery('')).called(1),
    );

    blocTest(
      'fetches queried symptom types',
      build: () async {
        mockBlocDelegate();
        return SymptomTypeBloc(repository: symptomTypeRepository);
      },
      act: (bloc) async => bloc.add(const FetchSymptomTypeQuery('Gas')),
      expect: [SymptomTypesLoaded(justGas)],
      verify: (bloc) async {
        verify(symptomTypeRepository.fetchQuery('Gas')).called(1);
        verify(analyticsService.logEvent('symptom_type_search')).called(1);
      },
    );

    blocTest(
      'streams queried symptom types',
      build: () async {
        mockBlocDelegate();
        return SymptomTypeBloc(repository: symptomTypeRepository);
      },
      act: (bloc) async => bloc.add(const StreamSymptomTypeQuery('Gas')),
      wait: const Duration(milliseconds: 100),
      expect: [SymptomTypesLoaded(justGas)],
      verify: (bloc) async {
        verify(symptomTypeRepository.streamQuery('Gas')).called(1);
        verify(analyticsService.logEvent('symptom_type_search')).called(1);
      },
    );
  });
}

class MockSymptomTypeRepository extends Mock implements SymptomTypeRepository {}
