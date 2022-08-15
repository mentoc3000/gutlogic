import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit() : super(const AnalysisLoaded());

  factory AnalysisCubit.fromContext(BuildContext context) {
    return AnalysisCubit();
  }
}
