import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/store/store_cubit.dart';
import '../../style/gl_colors.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/subscribe_list_view.dart';

class SubscribePage extends StatelessWidget {
  const SubscribePage();

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: AppBar(
        backgroundColor: GLColors.transparent,
        foregroundColor: GLColors.gray,
        elevation: 0.0,
      ),
      body: BlocProvider(
        create: (context) => StoreCubit.fromContext(context),
        child: const SubscribeListView(),
      ),
    );
  }
}
