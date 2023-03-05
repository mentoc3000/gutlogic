import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/symptom_type_count/symptom_type_count.dart';
import '../../../models/symptom_type.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/gl_calculating_widget.dart';
import '../../../widgets/gl_error_widget.dart';
import 'analysis_content_card.dart';
import 'analysis_section.dart';
import 'insufficient_data.dart';

class SymptomTypeCountSection extends StatelessWidget {
  static const Duration duration = Duration(days: 30);
  static const int maxSymptomTypes = 5;

  const SymptomTypeCountSection({Key? key}) : super(key: key);

  static Widget provisioned() {
    final since = DateTime.now().subtract(duration);
    return BlocProvider(
      create: (context) => SymptomTypeCountCubit.fromContext(context, countSince: since),
      child: const SymptomTypeCountSection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const heading = 'Most common symptom types this month';
    final subscribedContent = AnalysisContentCard(
      child: BlocBuilder<SymptomTypeCountCubit, SymptomTypeCountState>(builder: builder),
    );
    final exampleContent = AnalysisContentCard(
      child: _SymptomTypeCountChart(symptomTypeCount: _exampleData()),
    );
    return AnalysisSection(heading: heading, subscribedContent: subscribedContent, exampleContent: exampleContent);
  }

  Widget sizeAndCenter(Widget child) {
    const minHeight = 200.0;
    return SizedBox(
      height: minHeight,
      child: Center(child: child),
    );
  }

  Widget builder(BuildContext context, SymptomTypeCountState state) {
    if (state is SymptomTypeCountLoading) {
      return sizeAndCenter(GLCalculatingWidget());
    }
    if (state is SymptomTypeCountLoaded) {
      // final symptomTypeCount = state.symptomTypeCount;
      final hasData = state.symptomTypeCount.values.fold<bool>(false, (value, element) => value || element > 0);
      if (hasData) {
        return _SymptomTypeCountChart(symptomTypeCount: state.symptomTypeCount);
      } else {
        return sizeAndCenter(Stack(
          children: [
            InsufficientData(
              onTap: () => DefaultTabController.of(context).animateTo(1),
              message: 'Start tracking symptoms',
            ),
          ],
        ));
      }
    }
    if (state is SymptomTypeCountError) {
      return sizeAndCenter(GLErrorWidget(message: state.message));
    }
    return sizeAndCenter(const GLErrorWidget());
  }

  BuiltMap<SymptomType, int> _exampleData() {
    return BuiltMap<SymptomType, int>({
      SymptomType(id: 'id', name: 'Bloating'): 10,
      SymptomType(id: 'id', name: 'Diarrhea'): 4,
      SymptomType(id: 'id', name: 'Cramping'): 2,
      SymptomType(id: 'id', name: 'Pain'): 1,
    });
  }
}

class _SymptomTypeCountChart extends StatelessWidget {
  final BuiltMap<SymptomType, int> symptomTypeCount;

  const _SymptomTypeCountChart({Key? key, required this.symptomTypeCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEntries =
        symptomTypeCount.entries.sortedBy<num>((e) => -e.value).take(SymptomTypeCountSection.maxSymptomTypes);
    final maxCount = symptomTypeCount.values.reduce((value, element) => max(value, element));

    final rows = sortedEntries.map((e) {
      // Create a bar chart by setting the flex values of two adjacent Containers. The filled one has a constant value.
      // The empty one has a computed value. fracOfMax is the ratio of the count of the
      // given SymptomType to the count of the SymptomType with the highest count.
      const filledFlex = 100;
      final emptyFlex = e.value == 0 ? 9999 : (filledFlex * (maxCount - e.value) / e.value).floor();
      final fracOfMax = filledFlex / (filledFlex + emptyFlex);
      const minOpacity = 0.5;
      final opacity = 1 - (minOpacity * (1 - fracOfMax));

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 100.0,
              alignment: Alignment.centerRight,
              child: Text(e.key.name),
            ),
            Expanded(
              flex: filledFlex,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  height: 16.0,
                  decoration: BoxDecoration(
                    color: GLColors.green.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(1e4),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: emptyFlex,
              child: Container(),
            ),
          ],
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}
