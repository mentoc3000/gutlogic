import 'dart:async';
import 'dart:io' show Platform;

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../util/app_config.dart';
import 'api_service.dart';
import 'firebase/cloud_function_service.dart';
import 'firebase/remote_config_service.dart';

final _premiumIdConfigProd = RemoteConfiguration(
  key: 'iap_premium_id_prod',
  defaultValue: 'premium_subscription_monthly',
);
final _premiumIdConfigDev = RemoteConfiguration(
  key: 'iap_premium_id_dev',
  defaultValue: 'premium_subscription_monthly_dev',
);

class IapService {
  final InAppPurchase _inAppPurchase;
  final ApiService apiService;
  final String premiumId;
  final CloudFunction googlePlayVerify;

  Stream<List<PurchaseDetails>> get purchaseStream => _inAppPurchase.purchaseStream;

  IapService({
    InAppPurchase? inAppPurchase,
    required this.apiService,
    required this.premiumId,
    required this.googlePlayVerify,
  }) : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  factory IapService.fromContext(BuildContext context) {
    final config = context.read<AppConfig>();
    final premiumIdConfig = config.isProduction ? _premiumIdConfigProd : _premiumIdConfigDev;

    final remoteConfigService = context.read<RemoteConfigService>();
    final premiumId = remoteConfigService.get(premiumIdConfig);
    final googlePlayVerify = context.read<CloudFunctionService>().function('verifyPurchase');

    return IapService(apiService: context.read<ApiService>(), premiumId: premiumId, googlePlayVerify: googlePlayVerify);
  }

  Future<bool> verifyPurchase({required PurchaseDetails purchaseDetails, required String? userId}) async {
    if (userId == null) return false;

    final body = {
      'source': purchaseDetails.verificationData.source,
      'productId': purchaseDetails.productID,
      'verificationData': purchaseDetails.verificationData.serverVerificationData,
      'userId': userId,
    };
    try {
      if (Platform.isIOS) {
        await apiService.post(path: '/iap/verify', body: body);
      } else if (Platform.isAndroid) {
        await googlePlayVerify.call(body);
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<BuiltSet<ProductDetails>> _getProducts() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw StoreUnavailableException();
    }

    final ids = <String>{premiumId};
    final response = await _inAppPurchase.queryProductDetails(ids);

    return response.productDetails.toBuiltSet();
  }

  Future<ProductDetails> getPremiumProduct() async {
    final purchases = await _getProducts();
    return purchases.singleWhere(
      (p0) => p0.id == premiumId,
      orElse: () => throw ProductNotFoundException(),
    );
  }

  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    if (product.id == premiumId) {
      final successfullySent = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      if (!successfullySent) {
        throw IapException(message: 'Purchase request not successful');
      }
    } else {
      throw ProductNotFoundException();
    }
  }

  Future<void> completePurchase(PurchaseDetails purchaseDetails) => _inAppPurchase.completePurchase(purchaseDetails);

  Future<void> restore() async => _inAppPurchase.restorePurchases();

  /// Transfer purchase to different user
  /// Returns true if purchase was successfully transferred; false on failure or if user already has this purchase
  Future<bool> transferPurchase({required String userId, required PurchaseDetails purchaseDetails}) async {
    final body = {
      'source': purchaseDetails.verificationData.source,
      'productId': purchaseDetails.productID,
      'verificationData': purchaseDetails.verificationData.serverVerificationData,
      'userId': userId,
    };
    try {
      await apiService.post(path: '/iap/transfer', body: body);
    } catch (e) {
      return false;
    }
    return true;
  }
}

class IapException implements Exception {
  final String message;

  IapException({required this.message});
}

class StoreUnavailableException extends IapException {
  StoreUnavailableException() : super(message: 'IAP store is unavailable');
}

class ProductNotFoundException extends IapException {
  ProductNotFoundException() : super(message: 'Product not found');
}
