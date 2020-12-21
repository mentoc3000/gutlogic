import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/authentication/authentication.dart';
import '../../blocs/landing/landing_bloc.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/logo/gl_logo.dart';
import 'widgets/landing_page_buttons.dart';

class LandingPage extends StatelessWidget {
  static Widget provisioned() {
    return BlocProvider<LandingBloc>(
      create: (context) => LandingBloc.fromContext(context),
      child: LandingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const Expanded(child: GLLogo(text: true)),
              BlocBuilder<AuthenticationBloc, AuthenticationState>(builder: (context, state) {
                return state is Unauthenticated ? LandingPageButtons() : Container();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
