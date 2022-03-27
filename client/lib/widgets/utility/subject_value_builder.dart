import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import '../../pages/loading_page.dart';

/// Builds a widget using the current value of a subject. If the subject stream is empty, waits for the next value.
///
/// The builder is only called for the current or next value of the subject. If new values are emitted from the subject,
/// the builder will not get rebuilt. In this regard, this is different than a StreamBuilder.
class SubjectValueBuilder<T> extends StatelessWidget {
  final BehaviorSubject<T> subject;
  final AsyncWidgetBuilder<T> builder;

  const SubjectValueBuilder({required this.subject, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: subject.hasValue ? Future.value(subject.value) : subject.first, builder: builder);
  }
}

typedef ValueBuilder<T> = Widget Function(BuildContext, T);

/// Calls the builder with the resolved value of the future. Otherwise shows a loading page.
class LoadingBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final ValueBuilder<T> builder;

  const LoadingBuilder({required this.future, required this.builder});

  static LoadingBuilder<T> stream<T>({required ValueStream<T> stream, required ValueBuilder<T> builder}) {
    return LoadingBuilder(future: stream.hasValue ? Future.value(stream.value) : stream.first, builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        return snapshot.hasData ? builder(context, snapshot.requireData) : LoadingPage();
      },
    );
  }
}
