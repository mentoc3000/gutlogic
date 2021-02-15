import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/meal_element/meal_element.dart';
import '../../models/meal_element.dart';
import '../../widgets/cards/notes_card.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/quantity_card.dart';

class MealElementEntryPage extends StatefulWidget {
  static String tag = 'meal-element-entry-page';

  /// Wrap an meal element page with the necessary bloc providers, given the meal element.
  static Widget forMealElement(MealElement mealElement) {
    return BlocProvider(
      create: (context) => MealElementBloc.fromContext(context)..add(StreamMealElement(mealElement)),
      child: MealElementEntryPage(),
    );
  }

  @override
  _MealElementEntryPageState createState() => _MealElementEntryPageState();
}

class _MealElementEntryPageState extends State<MealElementEntryPage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
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
      _notesController.text = state.mealElement.notes;
      _amountController.text = QuantityCard.formatAmount(state.mealElement.quantity?.amount);
      _unitController.text = state.mealElement.quantity?.measure?.unit;
    }
  }

  bool listenWhen(MealElementState previousState, MealElementState currentState) {
    return currentState is MealElementLoaded && !(previousState is MealElementLoaded);
  }

  Widget appBarBuilder(BuildContext context, MealElementState state) {
    if (state is MealElementLoaded) {
      return GLAppBar(title: state.mealElement.foodReference.name);
    } else {
      return GLAppBar(title: 'Ingredient');
    }
  }

  Widget bodyBuilder(BuildContext context, MealElementState state) {
    final mealElementBloc = context.read<MealElementBloc>();
    if (state is MealElementLoading) {
      return LoadingPage();
    }

    if (state is MealElementLoaded) {
      final mealElement = state.mealElement;

      final cards = [
        QuantityCard(
          quantity: mealElement.quantity,
          onChanged: (quantity) => mealElementBloc.add(UpdateQuantity(quantity)),
          unitController: _unitController,
          amountController: _amountController,
          measureOptions: state.food?.measures,
        ),
        NotesCard(
          controller: _notesController,
          onChanged: (notes) => context.read<MealElementBloc>().add(UpdateNotes(notes)),
        )
      ];

      return Form(
        child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (BuildContext context, int index) =>
              Padding(padding: const EdgeInsets.all(1.0), child: cards[index]),
          padding: const EdgeInsets.all(0.0),
        ),
      );
    }

    if (state is MealElementError) {
      return ErrorPage(message: state.message);
    }

    return ErrorPage();
  }

  Widget builder(BuildContext context, MealElementState state) {
    return GLScaffold(
      appBar: appBarBuilder(context, state),
      body: bodyBuilder(context, state),
    );
  }
}
