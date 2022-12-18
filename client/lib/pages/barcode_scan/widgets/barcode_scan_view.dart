import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/models/food/food.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../blocs/upc/upc.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';
import 'barcode_loading_overlay.dart';

class BarcodeScanView extends StatefulWidget {
  final void Function(Food) onFood;

  const BarcodeScanView({required this.onFood});

  @override
  State<BarcodeScanView> createState() => _BarcodeScanViewState();
}

// MobileScanner needs to be in a stateful widget, leading to this weird construction with a BlocConsumer within a
// StatefulWidget. I don't like it, but I'm not sure what to do to make it better.
class _BarcodeScanViewState extends State<BarcodeScanView> with SingleTickerProviderStateMixin {
  // Controller must be part of state to maintain MobileScanner
  final controller = MobileScannerController();
  bool isDetecting = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpcCubit, UpcState>(
      builder: builder,
      listener: listener,
    );
  }

  Widget builder(BuildContext context, UpcState state) {
    final mobileScanner = MobileScanner(
      controller: controller,
      onDetect: onDetect,
    );

    // Sometimes during testing the scanner doesn't load. The black background helps make the X visible.
    // This issue has never been observed in production but the background remains, just in case.
    final background = Center(
      child: Container(color: Colors.black),
    );

    final overlay = state is UpcsFound ? const BarcodeLoadingOverlay() : Container();

    return Stack(children: [background, mobileScanner, overlay]);
  }

  void onDetect(BarcodeCapture capture) {
    if (!isDetecting) return;

    final upcs = capture.barcodes.map((barcode) => barcode.rawValue).whereType<String>();
    context.read<UpcCubit>().findFood(upcs: upcs);

    // Immediately set [isDetecting] to false to avoid triggering findFood multiple times
    setState(() {
      isDetecting = false;
    });
  }

  void listener(BuildContext context, UpcState state) {
    if (state is UpcScanning) {
      setState(() {
        isDetecting = true;
      });
    }
    if (state is UpcError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(ErrorSnackBar(text: state.message))
          .closed
          .then((reason) => context.read<UpcCubit>().reactivateScanner());
    }
    if (state is FoodNotFound) {
      ScaffoldMessenger.of(context)
          .showSnackBar(ErrorSnackBar(text: 'Could not find matching food'))
          .closed
          .then((reason) => context.read<UpcCubit>().reactivateScanner());
    }
    if (state is FoodFound) {
      Navigator.of(context).pop();
      widget.onFood(state.food);
    }
  }
}
