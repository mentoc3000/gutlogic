import 'package:flutter/material.dart';
import 'gutai_card.dart';

class NotesTile extends StatelessWidget {
  final String notes;
  final void Function(String) onChanged;

  NotesTile({this.notes, this.onChanged});

  @override
  Widget build(BuildContext context) {
    TextEditingController notesController = TextEditingController(text: notes);
    return GutAICard(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Notes'),
            TextField(
              keyboardType: TextInputType.multiline,
              controller: notesController,
              onChanged: (newValue) {
                  notes.replaceRange(0, null, newValue);
                  onChanged(newValue);
              },
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
