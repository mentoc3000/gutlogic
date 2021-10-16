import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

/// Builds a widget using the current value of a subject. If the subject stream is empty, waits for the next value.
///
/// The builder is only called for the current or next value of the subject. If new values are emitted from the subject,
/// the builder will not get rebuilt. In this regard, this is different than a StreamBuilder.
class SubjectValueBuilder<T> extends StatelessWidget {
  final BehaviorSubject<T> subject;
  final AsyncWidgetBuilder<T> builder;

  SubjectValueBuilder({required this.subject, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: subject.hasValue ? Future.value(subject.value) : subject.first, builder: builder);
  }
}
