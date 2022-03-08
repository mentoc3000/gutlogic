import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:provider/src/provider.dart';

import '../../resources/user_repository.dart';
import '../../routes/routes.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/logo/gl_logo.dart';
import '../../widgets/page_column.dart';

class LandingPage extends StatelessWidget {
  static Widget provisioned() {
    return LandingPage();
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      body: ConstrainedScrollView(builder: (context, constraints) => LandingPageBody()),
    );
  }
}

class LandingPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        const Expanded(child: GLLogo(text: true)),
        const Gap(40),
        GLPrimaryButton(
          child: const StretchedButtonContent(label: 'Create an account'),
          onPressed: () => Navigator.of(context).push(Routes.of(context).register),
        ),
        const Gap(20),
        GLSecondaryButton(
          child: const StretchedButtonContent(label: 'I already have an account'),
          onPressed: () => Navigator.of(context).push(Routes.of(context).login),
        ),
        const Gap(20),
        GLTertiaryButton(
          child: const StretchedButtonContent(label: 'I\'ll create an account later'),
          onPressed: () => context.read<UserRepository>().login(authentication: null),
        ),
      ]),
    );
  }
}
