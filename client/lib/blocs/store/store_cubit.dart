import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../models/user/application_user.dart';
import '../../resources/iap_service.dart';
import '../../resources/user_repository.dart';
import '../../util/app_config.dart';
import '../../util/logger.dart';
import 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  final UserRepository userRepository;
  final IapService iapService;
  final AppConfig appConfig;

  late final StreamSubscription<ApplicationUser?> userSubscription;
  late final StreamSubscription<List<PurchaseDetails>> purchaseDetailsSubscription;

  StoreCubit({
    required this.userRepository,
    required this.iapService,
    required this.appConfig,
  }) : super(const ProductsLoading()) {
    userSubscription = userRepository.stream.listen(_onUserData, onError: _onError);
    purchaseDetailsSubscription = iapService.purchaseStream.listen(_onPurchaseData, onError: _onError);

    unawaited(loadProducts());
  }

  factory StoreCubit.fromContext(BuildContext context) {
    return StoreCubit(
      userRepository: context.read<UserRepository>(),
      iapService: context.read<IapService>(),
      appConfig: context.read<AppConfig>(),
    );
  }

  @override
  Future<void> close() {
    userSubscription.cancel();
    purchaseDetailsSubscription.cancel();
    return super.close();
  }

  void _onPurchaseData(List<PurchaseDetails> purchaseDetailsList) async {
    await Future.forEach(purchaseDetailsList, (PurchaseDetails purchaseDetails) async {
      logger.d('Purchase status: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Send to server
        final user = userRepository.user;
        final verificationRequestSent = await iapService.verifyPurchase(
          purchaseDetails: purchaseDetails,
          userId: user?.id,
        );
        if (verificationRequestSent) {
          await loadProducts();
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        // Handle edge cases where purchase is not complete
        await iapService.completePurchase(purchaseDetails);
      }

      if (purchaseDetails.status == PurchaseStatus.restored) {
        await _completeRestore(purchaseDetails);
      }

      if (purchaseDetails.status == PurchaseStatus.canceled || purchaseDetails.status == PurchaseStatus.error) {
        await loadProducts();
      }
    });
  }

  void _onUserData(ApplicationUser? user) async {
    if (user != null && user.hasActivePremiumSubscription) {
      emit(const Subscribed());
    }
  }

  void _onError(Object error, StackTrace trace) {
    emit(SubscriptionError.fromError(error: error, trace: trace));
  }

  Future<void> loadProducts() async {
    try {
      final product = await iapService.getPremiumProduct();
      emit(ProductLoaded(product));
    } catch (error, trace) {
      logger.e(error);
      logger.e(trace);
      emit(const Unavailable());
    }
  }

  Future<void> subscribe(ProductDetails product) async {
    emit(const SubscriptionPending());
    try {
      await iapService.buy(product);
    } catch (error, trace) {
      emit(SubscriptionError.fromError(error: error, trace: trace));
      await loadProducts();
    }
  }

  Future<void> triggerRestore() async {
    emit(const SubscriptionPending());
    try {
      await iapService.restore();
    } catch (error, trace) {
      emit(SubscriptionError.fromError(error: error, trace: trace));
      await loadProducts();
    }
  }

  Future<void> _completeRestore(PurchaseDetails purchaseDetails) async {
    try {
      final userId = userRepository.user!.id;
      final transferSuccess = await iapService.transferPurchase(userId: userId, purchaseDetails: purchaseDetails);
      if (transferSuccess) {
      } else {
        await loadProducts();
      }
      await iapService.completePurchase(purchaseDetails);
    } catch (error, trace) {
      emit(SubscriptionError.fromError(error: error, trace: trace));
      await loadProducts();
    }
  }
}
