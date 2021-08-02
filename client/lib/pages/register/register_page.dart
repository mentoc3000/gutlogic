import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/register/register.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/page_column.dart';
import '../../widgets/snack_bars/error_snack_bar.dart';
import '../../widgets/untitled_back_bar.dart';
import 'widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  static Widget provisioned() {
    return BlocProvider<RegisterBloc>(
      create: (context) => RegisterBloc.fromContext(context),
      child: RegisterPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      body: PageColumn(
        builder: (context, constraints) {
          return Column(
            children: [
              const BlocListener<RegisterBloc, RegisterState>(
                listener: ErrorSnackBar.listen,
                child: SizedBox.shrink(), // TODO flutter_bloc barfs if child is null
              ),
              Container(height: 40, child: UntitledBackBar()),
              Container(height: constraints.maxHeight - 40, child: RegisterForm()),
            ],
          );
        },
      ),
    );
  }
}
