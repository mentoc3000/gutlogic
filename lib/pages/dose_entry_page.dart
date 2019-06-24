import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gut_ai/blocs/medicine_bloc.dart';
import '../models/dose.dart';
import '../models/medicine.dart';
import '../models/quantity.dart';
import '../widgets/quantity_view.dart';
import 'gutai_search_delegate.dart';

class DoseEntryPage extends StatefulWidget {
  static String tag = 'dose-entry-page';

  final Dose dose;
  final void Function(Dose) onSave;

  DoseEntryPage({this.dose, this.onSave});

  @override
  DoseEntryPageState createState() => DoseEntryPageState();
}

class DoseEntryPageState extends State<DoseEntryPage> {
  Medicine _medicine;
  Quantity _quantity;

  @override
  void initState() {
    super.initState();
    _medicine = widget.dose?.medicine ?? null;
    _quantity = widget.dose?.quantity ?? null;
  }

  @override
  void dispose() {
    if (_medicine != null && _quantity != null) {
      Dose dose = Dose(medicine: _medicine, quantity: _quantity);
      widget.onSave(dose);
    }
    super.dispose();
  }

  void showMedicineSearch(BuildContext context) {
    MedicineBloc medicineBloc = BlocProvider.of<MedicineBloc>(context);

    final onSelect = (medicine) => this._medicine = medicine;

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
    List<Widget> tiles = [
      QuantityView(
        quantity: _quantity,
        onChanged: (newQuantity) => _quantity = newQuantity,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_medicine?.name ?? 'Medicine'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showMedicineSearch(context),
          ),
        ],
      ),
      body: Form(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: tiles.length,
          itemBuilder: (context, index) =>
              Padding(padding: EdgeInsets.all(1.0), child: tiles[index]),
          padding: EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}
