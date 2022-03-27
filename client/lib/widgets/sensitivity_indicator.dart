import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensitivity/sensitivity.dart';
import '../models/sensitivity/sensitivity_level.dart';
import '../models/sensitivity/sensitivity_source.dart';
import '../style/gl_colors.dart';
import 'gl_icons.dart';

class SensitivityIndicator extends StatelessWidget {
  final Future<Sensitivity> sensitivity;

  const SensitivityIndicator(this.sensitivity);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Sensitivity>(
      future: sensitivity,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final sensitivity = snapshot.data ?? Sensitivity.unknown;
          final color = GLColors.fromSensitivityLevel(sensitivity.level);
          final iconData =
              sensitivity.source == SensitivitySource.prediction || sensitivity.level == SensitivityLevel.unknown
                  ? GLIcons.predictedSensitivity
                  : GLIcons.userSensitivity;
          return Icon(iconData, color: color);
        } else {
          return const _SensitivityIndicatorLoading();
        }
      },
    );
  }
}

class _SensitivityIndicatorLoading extends StatefulWidget {
  const _SensitivityIndicatorLoading({Key? key}) : super(key: key);

  @override
  __SensitivityIndicatorLoadingState createState() => __SensitivityIndicatorLoadingState();
}

class __SensitivityIndicatorLoadingState extends State<_SensitivityIndicatorLoading>
    with SingleTickerProviderStateMixin {
  late final Animation<Color?> animation;
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat(reverse: true);
    animation = ColorTween(begin: GLColors.lighterGray, end: GLColors.lightestGray).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Icon(GLIcons.predictedSensitivity, color: animation.value),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
