import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../blocs/consent/consent.dart';
import '../../routes/routes.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/page_column.dart';
import 'widgets/consent_form.dart';
import 'widgets/consent_header.dart';

class ConsentPage extends StatelessWidget {
  static Widget provisioned() {
    return ConsentCubit.provider(child: ConsentPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConsentCubit, ConsentState>(
      listener: listener,
      child: GLScaffold(body: ConstrainedScrollView(builder: (context, constraints) => ConsentPageBody())),
    );
  }

  static void listener(BuildContext context, ConsentState state) {
    if (state is ConsentSuccess) {
      Navigator.of(context).pushAndRemoveUntil(Routes.of(context).main, (_) => false);
    }
  }
}

class ConsentPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        ConsentHeader(),
        const Gap(40),
        ConsentForm(),
      ]),
    );
  }
}
