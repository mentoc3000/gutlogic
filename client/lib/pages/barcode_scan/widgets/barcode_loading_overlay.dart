import 'package:flutter/widgets.dart';

import '../../../widgets/gl_loading_widget.dart';

class BarcodeLoadingOverlay extends StatelessWidget {
  const BarcodeLoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const translucent = Color.fromRGBO(0, 0, 0, 0.5);
    return Center(
      child: Container(
        color: translucent,
        child: GLLoadingWidget(),
      ),
    );
  }
}
