import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/consent/consent.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/consent_form.dart';

class ConsentPage extends StatelessWidget {
  static Widget provisioned() {
    return BlocProvider<ConsentBloc>(
      create: (context) => ConsentBloc.fromContext(context),
      child: ConsentPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ConsentForm(),
      ),
    );
  }
}
