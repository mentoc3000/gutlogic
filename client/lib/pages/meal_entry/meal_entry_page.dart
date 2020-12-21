import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/food/food.dart';
import '../../blocs/meal_entry/meal_entry.dart';
import '../../models/diary_entry/meal_entry.dart';
import '../../widgets/cards/datetime_card.dart';
import '../../widgets/cards/notes_card.dart';
import '../../widgets/floating_action_buttons/add_floating_action_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/snack_bars/undo_delete_snack_bar.dart';
import '../error_page.dart';
import '../loading_page.dart';
import '../search_delegate/food_search_delegate.dart';
import 'widgets/add_food_dialog.dart';
import 'widgets/meal_elements_card.dart';

class MealEntryPage extends StatefulWidget {
  static String tag = 'meal-entry-page';

  static Widget forNewEntry() {
    return BlocProvider(
      create: (context) => MealEntryBloc.fromContext(context)..add(const CreateAndStreamMealEntry()),
      child: MealEntryPage(),
    );
  }

  static Widget forExistingEntry(MealEntry entry) {
    return BlocProvider(
      create: (context) => MealEntryBloc.fromContext(context)..add(StreamMealEntry(entry)),
      child: MealEntryPage(),
    );
  }

  @override
  _MealEntryPageState createState() => _MealEntryPageState();
}

class _MealEntryPageState extends State<MealEntryPage> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Food & Drink'),
      body: BlocConsumer<MealEntryBloc, MealEntryState>(
        builder: builder,
        listener: listener,
        listenWhen: listenWhen,
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () => addMealElement(context),
      ),
    );
  }

  void listener(BuildContext context, MealEntryState state) {
    if (state is MealEntryLoaded) {
      _notesController.text = state.diaryEntry.notes;
    }
    if (state is MealElementDeleted) {
      final snackBar = UndoDeleteSnackBar(
        name: state.mealElement.foodReference.name,
        onUndelete: () => MealEntryBloc.fromContext(context)
            .add(UndeleteMealElement(mealEntry: state.mealEntry, mealElement: state.mealElement)),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  bool listenWhen(MealEntryState previousState, MealEntryState currentState) {
    final loadedAfterSomethingElse = currentState is MealEntryLoaded && !(previousState is MealEntryLoaded);
    final deleted = currentState is MealElementDeleted;
    return loadedAfterSomethingElse || deleted;
  }

  Future<void> addFood(BuildContext context, {String initialFoodName = ''}) async {
    final foodBloc = context.bloc<FoodBloc>();

    final foodName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AddFoodDialog(initialFoodName: initialFoodName),
    );

    if (foodName != null) foodBloc.add(CreateCustomFood(foodName));
  }

  void addMealElement(BuildContext context) {
    final foodBloc = BlocProvider.of<FoodBloc>(context);
    final mealEntryBloc = context.bloc<MealEntryBloc>();

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodBloc: foodBloc,
        onSelect: (food) => mealEntryBloc.add(AddMealElement(food)),
        onAdd: (foodName) => addFood(context, initialFoodName: foodName),
        onDelete: (food) => foodBloc.add(DeleteCustomFood(food)),
      ),
    );
  }

  List<Widget> buildCards(BuildContext context, MealEntry entry) {
    final mealEntryBloc = context.bloc<MealEntryBloc>();
    return [
      DateTimeCard(
        dateTime: entry.datetime,
        onChanged: (DateTime datetime) => mealEntryBloc.add(UpdateMealEntryDateTime(datetime)),
      ),
      MealElementsCard(mealEntry: entry),
      NotesCard(
        controller: _notesController,
        onChanged: (String notes) => mealEntryBloc.add(UpdateMealEntryNotes(notes)),
      )
    ];
  }

  Widget builder(BuildContext context, MealEntryState state) {
    if (state is MealEntryLoading) {
      return LoadingPage();
    }

    if (state is MealEntryLoaded) {
      final mealEntry = state.diaryEntry as MealEntry;
      final items = buildCards(context, mealEntry);
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) =>
            Padding(padding: const EdgeInsets.all(1.0), child: items[index]),
        padding: const EdgeInsets.all(0.0),
      );
    }

    if (state is MealEntryError) {
      return ErrorPage(message: state.message);
    }

    return ErrorPage();
  }
}
