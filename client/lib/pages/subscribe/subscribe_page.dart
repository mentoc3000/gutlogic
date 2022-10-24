import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/store/store_cubit.dart';
import '../../style/gl_colors.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/subscribe_list_view.dart';

class SubscribePage extends StatelessWidget {
  final VoidCallback? onSubscribed;

  const SubscribePage({this.onSubscribed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF188774),
            Color(0xFF18AD7C),
          ],
        ),
      ),
      child: GLScaffold(
        backgroundColor: GLColors.transparent,
        appBar: AppBar(
          backgroundColor: GLColors.transparent,
          foregroundColor: GLColors.white,
          elevation: 0.0,
        ),
        body: BlocProvider(
          create: (context) => StoreCubit.fromContext(context),
          child: SubscribeListView(onSubscribed: onSubscribed),
        ),
      ),
    );
  }
}
