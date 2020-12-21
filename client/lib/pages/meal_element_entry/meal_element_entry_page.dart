import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/meal_element/meal_element.dart';
import '../../models/meal_element.dart';
import '../../widgets/cards/notes_card.dart';
// import '../../widgets/cards/quantity_card.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../error_page.dart';
import '../loading_page.dart';

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

  MealElementBloc _mealElementBloc;

  @override
  void initState() {
    super.initState();
    _mealElementBloc = context.bloc<MealElementBloc>();
  }

  @override
  void dispose() {
    _notesController.dispose();
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
      _notesController.text = state.mealElement.notes;
    }
  }

  bool listenWhen(MealElementState previousState, MealElementState currentState) {
    return currentState is MealElementLoaded && !(previousState is MealElementLoaded);
  }

  // void showFoodSearch(BuildContext context, MealElement mealElement, MealElementBloc mealElementBloc) {
  //   final foodBloc = BlocProvider.of<FoodBloc>(context);

  //   showSearch(
  //     context: context,
  //     delegate: FoodSearchDelegate(
  //       foodBloc: foodBloc,
  //       onSelect: (food) => mealElementBloc.add(UpdateFood(food)),
  //     ),
  //   );
  // }

  Widget builder(BuildContext context, MealElementState state) {
    List<Widget> buildCards(MealElement mealElement) {
      return [
        // QuantityCard(
        //   quantity: mealElement.quantity,
        //   onChanged: (quantity) => _mealElementBloc.add(UpdateQuantity(quantity)),
        // ),
        NotesCard(
          controller: _notesController,
          onChanged: (notes) => _mealElementBloc.add(UpdateNotes(notes)),
        )
      ];
    }

    Widget buildPage(MealElementState state) {
      final defaultAppBar = GLAppBar(title: 'Ingredient');

      if (state is MealElementLoading) {
        return GLScaffold(
          appBar: defaultAppBar,
          body: LoadingPage(),
        );
      }

      if (state is MealElementLoaded) {
        final mealElement = state.mealElement;
        final cards = buildCards(mealElement);
        return GLScaffold(
          appBar: GLAppBar(title: mealElement.foodReference.name),
          body: Form(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (BuildContext context, int index) =>
                  Padding(padding: const EdgeInsets.all(1.0), child: cards[index]),
              padding: const EdgeInsets.all(0.0),
            ),
          ),
        );
      }

      if (state is MealElementError) {
        return GLScaffold(
          appBar: defaultAppBar,
          body: ErrorPage(message: state.message),
        );
      }

      return GLScaffold(
        appBar: defaultAppBar,
        body: ErrorPage(),
      );
    }

    return buildPage(state);
  }
}
