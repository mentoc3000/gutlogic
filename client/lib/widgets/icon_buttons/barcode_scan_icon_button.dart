import 'package:flutter/material.dart';
import 'package:gutlogic/models/food/food.dart';

import '../../routes/routes.dart';
import '../gl_icons.dart';

class BarcodeScanIconButton extends StatelessWidget {
  final void Function(Food) onFood;
  const BarcodeScanIconButton({required this.onFood});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(GLIcons.barcode),
      onPressed: () {
        // TODO: improve navigation for barcode scanner (#100)
        Navigator.pushReplacement(context, Routes.of(context).createBarcodeScanRoute(onFood: onFood));
      },
    );
  }
}
