import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc/src/bloc_provider.dart';
import 'package:flutter_bloc/src/repository_provider.dart';
import 'package:provider/provider.dart';
import 'package:nested/nested.dart';

/// Wrap MultiRepositoryProvider and MultiBlocProvider in a consolidated single widget. We don't use MultiProvider
/// directly for blocs and repositories because flutter_bloc might [remove support](https://github.com/felangel/bloc/issues/712)
///  for provider. The repositories are always provided above the blocs in the MultiResourceProvider, so that the blocs
/// can use them.
class MultiResourceProvider extends StatelessWidget {
  // We have to use the internal SingleChildWidget types here to preserve the provider type information.
  final List<BlocProviderSingleChildWidget> blocs;
  final List<RepositoryProviderSingleChildWidget> repos;
  final List<SingleChildWidget> services;

  final Widget child;

  MultiResourceProvider({Key key, this.repos, this.blocs, this.services, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return provideServices(services, provideRepos(repos, provideBlocs(blocs, child)));
  }

  static Widget provideServices(List<SingleChildWidget> services, Widget child) {
    if (services?.isEmpty ?? true) {
      return child;
    }
    return MultiProvider(providers: services, child: child);
  }

  static Widget provideRepos(List<RepositoryProviderSingleChildWidget> repos, Widget child) {
    if (repos?.isEmpty ?? true) {
      return child;
    }
    return MultiRepositoryProvider(providers: repos, child: child);
  }

  static Widget provideBlocs(List<BlocProviderSingleChildWidget> blocs, Widget child) {
    if (blocs?.isEmpty ?? true) {
      return child;
    }
    return MultiBlocProvider(providers: blocs, child: child);
  }
}
