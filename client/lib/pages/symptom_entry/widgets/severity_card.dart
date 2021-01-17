import 'package:flutter/widgets.dart';
import '../../../models/severity.dart';
import '../../../widgets/cards/headed_card.dart';
import 'severity_slider.dart';

class SeverityCard extends StatefulWidget {
  final Severity severity;
  final Function(Severity) onChanged;

  const SeverityCard({this.severity, this.onChanged});

  @override
  _SeverityCardState createState() => _SeverityCardState();
}

class _SeverityCardState extends State<SeverityCard> {
  Severity _severity;

  @override
  void initState() {
    super.initState();
    _severity = widget.severity;
  }

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Severity',
      content: SeveritySlider(
        initialSeverity: _severity,
        onChange: (Severity newValue) => setState(() {
          if (_severity == newValue) {
            return;
          }
          _severity = newValue;
          widget.onChanged(newValue);
        }),
      ),
    );
  }
}
