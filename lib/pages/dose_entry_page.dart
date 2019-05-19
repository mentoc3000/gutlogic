import 'package:flutter/material.dart';
import 'package:gut_ai/blocs/medicine_bloc.dart';
import '../models/dose.dart';
import '../widgets/quantity_view.dart';
import 'gutai_search_delegate.dart';

class DoseEntryPage extends StatefulWidget {
  static String tag = 'dose-entry-page';

  final Dose dose;

  DoseEntryPage({this.dose});

  @override
  DoseEntryPageState createState() => DoseEntryPageState();
}

class DoseEntryPageState extends State<DoseEntryPage> {
  Dose _dose;

  @override
  void initState() {
    super.initState();
    _dose = widget.dose;
  }

  List<Widget> buildItems() {
    return [
      QuantityView(
        quantity: _dose.quantity,
      ),
    ];
  }

  void showFoodSearch(BuildContext context) {
    MedicineBloc medicineBloc = MedicineBloc();

    final onSelect = (medicine) => this._dose = Dose(medicine: medicine);

    showSearch(
      context: context,
      delegate: GutAiSearchDelegate(
        searchableBloc: medicineBloc,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = buildItems();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_dose?.medicine?.name ?? 'Medicine'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showFoodSearch(context),
          ),
        ],
      ),
      body: Form(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              Padding(padding: EdgeInsets.all(1.0), child: items[index]),
          padding: EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}
