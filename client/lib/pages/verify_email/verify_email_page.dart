import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/verify_email/verify_email.dart';
import '../../resources/firebase/remote_config_service.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/verify_email_form.dart';

final _messageConfig =
    RemoteConfiguration(key: 'email_verification_message', defaultValue: 'Please check your email to verify');

class VerifyEmailPage extends StatelessWidget {
  final String email;

  VerifyEmailPage({@required this.email});

  static Widget provisioned({@required String email}) {
    return BlocProvider<VerifyEmailBloc>(
      create: (context) => VerifyEmailBloc.fromContext(context),
      child: VerifyEmailPage(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig = context.read<RemoteConfigService>();
    final message = remoteConfig.get(_messageConfig);

    return GLScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: VerifyEmailForm(message: message, email: email),
      ),
    );
  }
}
