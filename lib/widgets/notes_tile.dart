import 'package:flutter/material.dart';
import 'gutai_card.dart';

class NotesTile extends StatefulWidget {
  final String notes;

  NotesTile({this.notes});

  @override
  _NotesTileState createState() => _NotesTileState();
}

class _NotesTileState extends State<NotesTile> {
  TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.notes);
  }

  @override
  Widget build(BuildContext context) {
    return GutAICard(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Notes'),
            TextField(
              keyboardType: TextInputType.multiline,
              controller: _notesController,
              onChanged: (newValue) =>
                  widget.notes.replaceRange(0, null, newValue),
            ),
          ],
        ),
      ),
    );
  }
}
