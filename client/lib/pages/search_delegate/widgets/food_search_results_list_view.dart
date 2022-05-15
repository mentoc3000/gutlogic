import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';

import '../../../models/food/food.dart';
import '../../../style/gl_color_scheme.dart';
import '../../../widgets/fab_guide.dart';
import '../../../widgets/powered_by_edamam.dart';
import 'food_search_result_tile.dart';

class FoodSearchResultsListView extends StatelessWidget {
  final void Function(Food) onTap;
  final BuiltList<Food> foods;

  const FoodSearchResultsListView({Key? key, required this.foods, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    return Stack(
      children: [
        SafeArea(
          child: PoweredByEdamam(
            child: ListView.builder(
              itemCount: foods.length + 1,
              shrinkWrap: true,
              controller: controller,
              itemBuilder: (BuildContext context, int index) {
                if (index < foods.length) {
                  final result = foods[index];
                  return FoodSearchResultTile(
                    food: result,
                    onTap: () => onTap(result),
                  );
                } else {
                  return const SizedBox(height: _CustomFoodGuide.height);
                }
              },
            ),
          ),
        ),
        _CustomFoodGuide(controller: controller),
      ],
    );
  }
}

class _CustomFoodGuide extends StatefulWidget {
  final ScrollController controller;
  static const height = 200.0;
  const _CustomFoodGuide({Key? key, required this.controller}) : super(key: key);

  @override
  __CustomFoodGuideState createState() => __CustomFoodGuideState();
}

class __CustomFoodGuideState extends State<_CustomFoodGuide> {
  double opacity = 0.0;

  void _updateOpacity() {
    final position = widget.controller.position;
    final newOpacity =
        position.extentAfter < _CustomFoodGuide.height ? (1.0 - position.extentAfter / _CustomFoodGuide.height) : 0.0;
    if (newOpacity != opacity) {
      setState(() {
        opacity = newOpacity;
      });
    }
  }

  @override
  void initState() {
    widget.controller.addListener(_updateOpacity);

    // Update opacity once controller is attached to list view
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateOpacity();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Container(
          alignment: const Alignment(1.0, 1.0),
          child: SizedBox(
            height: _CustomFoodGuide.height,
            child: Container(
              color: glColorScheme.background,
              child: const FabGuide(message: "Can't find what you're looking for?\nCreate a custom food!"),
            ),
          ),
        ),
      ),
    );
  }
}
