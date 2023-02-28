import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../style/gl_text_style.dart';

final _arrowImage = SvgPicture.asset(
  'assets/curved_arrow.svg',
  colorFilter: ColorFilter.mode(guideTextStyle.color!, BlendMode.srcIn),
);

class FabGuide extends StatelessWidget {
  final String message;

  const FabGuide({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: const Alignment(1.0, 1.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 250),
                child: Text(message, style: guideTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 80),
                child: SizedBox(height: 100, width: 89, child: _arrowImage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
