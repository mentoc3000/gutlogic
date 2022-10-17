import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/store/store.dart';

import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/buttons/gl_flat_button.dart';
import '../../../widgets/gl_loading_widget.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';

class SubscribeListView extends StatelessWidget {
  const SubscribeListView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildStoreContent(context)],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStoreContent(BuildContext context) {
    return BlocConsumer<StoreCubit, StoreState>(
      builder: storeContentBuilder,
      buildWhen: storeContentBuildWhen,
      listener: storeContentListener,
    );
  }

  Widget storeContentBuilder(BuildContext context, StoreState state) {
    final subscriptionCubit = context.read<StoreCubit>();

    if (state is ProductsLoading || state is SubscriptionPending) {
      return GLFlatButton(onPressed: () {}, child: GLLoadingWidget());
    } else if (state is ProductLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Purchase Premium for ${state.product.price} per month.'),
          GLPrimaryButton(
            onPressed: () => unawaited(subscriptionCubit.subscribe(state.product)),
            child: const ShrinkWrappedButtonContent(label: 'Subscribe'),
          ),
          GLTertiaryButton(
            onPressed: () => unawaited(subscriptionCubit.triggerRestore()),
            child: const ShrinkWrappedButtonContent(label: 'Restore Purchase'),
          )
        ],
      );
    } else {
      return GLFlatButton(onPressed: () {}, child: const Text('Purchase cannot be made right now.'));
    }
  }

  void storeContentListener(BuildContext context, StoreState state) {
    if (state is Subscribed) {
      Navigator.of(context).pop();
    }
    if (state is SubscriptionError) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    }
  }

  bool storeContentBuildWhen(StoreState previous, StoreState current) {
    return current is! Subscribed && current is! SubscriptionError;
  }
}
