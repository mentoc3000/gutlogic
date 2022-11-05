import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/meal_element/meal_element.dart';
import '../../models/meal_element.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_loading_widget.dart';
import 'widgets/meal_element_entry_list_view.dart';
import 'widgets/quantity_card.dart';

class MealElementEntryPage extends StatelessWidget {
  static String tag = 'meal-element-entry-page';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  /// Wrap an meal element page with the necessary bloc providers, given the meal element.
  static Widget forMealElement(MealElement mealElement) {
    return BlocProvider(
      create: (context) => MealElementBloc.fromContext(context)..add(StreamMealElement(mealElement)),
      child: MealElementEntryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealElementBloc, MealElementState>(
      builder: builder,
      listener: listener,
      listenWhen: listenWhen,
    );
  }

  void listener(BuildContext context, MealElementState state) {
    if (state is MealElementLoaded) {
      // Update text here to allow changes to save without submitting, but avoid cursor jumps
      _notesController.text = state.mealElement.notes ?? '';
      _amountController.text = QuantityCard.formatAmount(state.mealElement.quantity?.amount);
      _unitController.text = state.mealElement.quantity?.measure?.unit ?? '';
    }
  }

  bool listenWhen(MealElementState previousState, MealElementState currentState) {
    return currentState is MealElementLoaded && previousState is! MealElementLoaded;
  }

  AppBar appBarBuilder(BuildContext context, MealElementState state) {
    if (state is MealElementLoaded) {
      return GLAppBar(title: state.mealElement.foodReference.name);
    } else {
      return GLAppBar(title: 'Ingredient');
    }
  }

  Widget bodyBuilder(BuildContext context, MealElementState state) {
    if (state is MealElementLoading) {
      return GLLoadingWidget();
    }

    if (state is MealElementLoaded) {
      return MealElementEntryListView(
        mealElement: state.mealElement,
        food: state.food,
        notesController: _notesController,
        amountController: _amountController,
        unitController: _unitController,
      );
    }

    if (state is MealElementError) {
      return GLErrorWidget(message: state.message);
    }

    return const GLErrorWidget();
  }

  Widget builder(BuildContext context, MealElementState state) {
    return GLScaffold(
      appBar: appBarBuilder(context, state),
      body: bodyBuilder(context, state),
    );
  }
}
