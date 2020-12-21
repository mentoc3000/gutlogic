import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/login/login.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/page_column.dart';
import '../../widgets/untitled_back_bar.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  static Widget provisioned() {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc.fromContext(context),
      child: LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      body: PageColumn(
        builder: (context, constraints) {
          return Column(
            children: [
              Container(height: 60, child: UntitledBackBar()),
              Container(height: constraints.maxHeight - 60, child: LoginForm()),
            ],
          );
        },
      ),
    );
  }
}
