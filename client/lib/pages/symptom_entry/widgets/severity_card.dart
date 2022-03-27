import 'package:flutter/widgets.dart';

import '../../../models/severity.dart';
import '../../../widgets/cards/headed_card.dart';
import 'severity_slider.dart';

class SeverityCard extends StatefulWidget {
  final Severity severity;
  final void Function(Severity)? onChanged;

  const SeverityCard({required this.severity, this.onChanged});

  @override
  _SeverityCardState createState() => _SeverityCardState();
}

class _SeverityCardState extends State<SeverityCard> {
  late Severity severity;

  @override
  void initState() {
    super.initState();
    severity = widget.severity;
  }

  @override
  Widget build(BuildContext context) {
    return HeadedCard(
      heading: 'Severity',
      content: SeveritySlider(
        initialSeverity: severity,
        onChange: onChange,
      ),
    );
  }

  void onChange(Severity value) {
    if (severity == value) return;

    setState(() {
      severity = value;
      widget.onChanged?.call(value);
    });
  }
}
