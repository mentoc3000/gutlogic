import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension ProviderExtensions on BuildContext {
  /// Returns true if the context has a provider of the specified type.
  bool has<T>() => read<T?>() != null;
}
