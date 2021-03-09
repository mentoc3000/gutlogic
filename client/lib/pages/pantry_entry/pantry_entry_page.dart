import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/pantry_entry/pantry_entry.dart';
import '../../models/food/food.dart';
import '../../models/pantry_entry.dart';
import '../../resources/pantry_repository.dart';
import '../../widgets/cards/notes_card.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/sensitivity_slider_card.dart';

class PantryEntryPage extends StatefulWidget {
  static String tag = 'pantryentry-entry-page';

  /// Wrap an pantryentry page with the necessary bloc providers, given the pantryentry.
  static Widget forPantryEntry(PantryEntry pantryEntry) {
    return BlocProvider(
      create: (context) {
        return PantryEntryBloc(repository: context.read<PantryRepository>())..add(StreamEntry(pantryEntry));
      },
      child: PantryEntryPage(),
    );
  }

  /// Wrap an pantryentry page with the necessary bloc providers, given the pantryentry.
  static Widget forId(String id) {
    return BlocProvider(
      create: (context) {
        return PantryEntryBloc(repository: context.read<PantryRepository>())..add(StreamId(id));
      },
      child: PantryEntryPage(),
    );
  }

  /// Wrap an pantryentry page with the necessary bloc providers, given the meal entry.
  static Widget forFood(Food food) {
    return BlocProvider(
      create: (context) {
        return PantryEntryBloc(repository: context.read<PantryRepository>())..add(CreateAndStreamEntry(food));
      },
      child: PantryEntryPage(),
    );
  }

  @override
  _PantryEntryPageState createState() => _PantryEntryPageState();
}

class _PantryEntryPageState extends State<PantryEntryPage> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantryEntryBloc, PantryEntryState>(builder: builder, listener: listener);
  }

  void listener(BuildContext context, PantryEntryState state) {
    if (state is PantryEntryLoaded) {
      _notesController.text = state.pantryEntry.notes;
    }
  }

  Widget builder(BuildContext context, PantryEntryState state) {
    final pantryBloc = context.read<PantryEntryBloc>();
    final defaultAppBar = GLAppBar(title: 'Food');

    List<Widget> buildCards(PantryEntry pantryEntry) {
      return [
        SensitivitySlider(
          sensitivityLevel: pantryEntry.sensitivity,
          onChanged: (sensitivity) => pantryBloc.add(UpdateSensitivity(sensitivity)),
        ),
        NotesCard(
          controller: _notesController,
          onChanged: (notes) => pantryBloc.add(UpdateNotes(notes)),
        )
      ];
    }

    if (state is PantryEntryLoading) {
      return GLScaffold(
        appBar: defaultAppBar,
        body: LoadingPage(),
      );
    }
    if (state is PantryEntryLoaded) {
      final pantryEntry = state.pantryEntry;
      final cards = buildCards(pantryEntry);
      return GLScaffold(
        appBar: GLAppBar(title: pantryEntry.foodReference.name),
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
    if (state is PantryEntryError) {
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
}
