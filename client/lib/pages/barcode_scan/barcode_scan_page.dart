import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/models/food/food.dart';

import '../../blocs/upc/upc.dart';
import '../../style/gl_colors.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/barcode_scan_view.dart';

class BarcodeScanPage extends StatelessWidget {
  final void Function(Food) onFood;

  const BarcodeScanPage({required this.onFood});

  static Widget provided({required void Function(Food) onFood}) {
    return BlocProvider(
      create: UpcCubit.fromContext,
      child: BarcodeScanPage(onFood: onFood),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      backgroundColor: GLColors.transparent,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: GLColors.transparent,
        foregroundColor: GLColors.white,
        elevation: 0.0,
      ),
      body: BarcodeScanView(onFood: onFood),
    );
  }
}
