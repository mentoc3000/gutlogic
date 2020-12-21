import 'package:flutter/widgets.dart';
import '../form_fields/multiline_text_field.dart';
import 'headed_card.dart';

class NotesCard extends StatelessWidget {
  final void Function(String) onChanged;
  final TextEditingController controller;

  const NotesCard({@required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Notes',
      content: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: MultilineTextField(
          controller: controller,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
