import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:plant_tracker/Service/adservice.dart';

class IapService {
  IapService._();
  static final IapService instance = IapService._();

  static const String removeAdsProductId = 'remove_ads';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  ProductDetails? removeAdsProduct;
  bool isAvailable = false;
  bool isLoading = false;

  Future<void> init() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('IAP stream error: $error');
      },
    );

    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    isLoading = true;
    final response = await _iap.queryProductDetails({removeAdsProductId});

    if (response.error != null) {
      debugPrint('IAP query error: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP product not found: ${response.notFoundIDs}');
    }
    if (response.productDetails.isNotEmpty) {
      removeAdsProduct = response.productDetails.first;
    }
    isLoading = false;
  }

  Future<void> buyRemoveAds() async {
    if (removeAdsProduct == null) {
      debugPrint('Remove ads product not loaded yet');
      return;
    }
    final purchaseParam = PurchaseParam(productDetails: removeAdsProduct!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchase.error}');
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == removeAdsProductId) {
          await AdService.instance.setAdsRemoved(true);
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}