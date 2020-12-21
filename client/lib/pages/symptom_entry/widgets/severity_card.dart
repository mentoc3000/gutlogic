import 'package:flutter/widgets.dart';
import '../../../widgets/cards/headed_card.dart';
import 'severity_slider.dart';

class SeverityCard extends StatefulWidget {
  final double severity;
  final Function(double) onChanged;

  const SeverityCard({this.severity, this.onChanged});

  @override
  _SeverityCardState createState() => _SeverityCardState();
}

class _SeverityCardState extends State<SeverityCard> {
  double _severity;

  @override
  void initState() {
    super.initState();
    _severity = widget.severity;
  }

  @override
  Widget build(BuildContext context) {
    int severityToSliderValue(double severity) => (4 - severity).round();

    double sliderValueToSeverity(int value) => (4 - value).roundToDouble();

    return HeadedCard(
      heading: 'Severity',
      content: SeveritySlider(
        initialValue: severityToSliderValue(_severity),
        onChange: (newValue) => setState(() {
          final newSeverity = sliderValueToSeverity(newValue);
          if (_severity == newSeverity) {
            return;
          }
          _severity = newSeverity;
          widget.onChanged(newSeverity);
        }),
      ),
    );
  }
}
