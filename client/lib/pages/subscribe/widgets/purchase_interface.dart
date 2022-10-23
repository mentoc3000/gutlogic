import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/store/store.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/gl_loading_widget.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';

class PurchaseInterface extends StatelessWidget {
  const PurchaseInterface({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Container(
        alignment: Alignment.topCenter,
        child: BlocConsumer<StoreCubit, StoreState>(
          builder: storeContentBuilder,
          buildWhen: storeContentBuildWhen,
          listener: storeContentListener,
        ),
      ),
    );
  }

  Widget storeContentBuilder(BuildContext context, StoreState state) {
    const style = TextStyle(color: GLColors.white, fontSize: 16.0);
    final subscriptionCubit = context.read<StoreCubit>();

    if (state is ProductsLoading || state is SubscriptionPending) {
      return GLFlatButton(onPressed: () {}, child: GLLoadingWidget());
    } else if (state is ProductLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DefaultTextStyle(
              style: TextStyle(color: GLColors.onCta, fontSize: 18.0),
              child: GLCtaButton(
                onPressed: () => subscriptionCubit.subscribe(state.product),
                child: const StretchedButtonContent(label: 'Subscribe', textStyle: TextStyle(fontSize: 18.0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Text('${state.product.price} per month', style: style),
            ),
            GLTertiaryButton(
              onPressed: () => unawaited(subscriptionCubit.triggerRestore()),
              child: const ShrinkWrappedButtonContent(label: 'Restore purchase', textStyle: style),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: GLFlatButton(
          onPressed: () {},
          child: const Text('Purchase cannot be made right now', style: style),
        ),
      );
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
