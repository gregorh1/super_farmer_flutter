import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/premium_provider.dart';

/// Wraps the in_app_purchase plugin for premium unlock purchases.
class PurchaseService {
  PurchaseService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _iap = InAppPurchase.instance;

  /// Callback invoked when a purchase completes successfully.
  VoidCallback? onPurchaseSuccess;

  /// Callback invoked when a purchase fails or is cancelled.
  void Function(String error)? onPurchaseError;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP not available on this device');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('IAP stream error: $error');
      },
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify and deliver the product
          _completePurchase(purchase);
          onPurchaseSuccess?.call();
        case PurchaseStatus.error:
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          onPurchaseError?.call(
            purchase.error?.message ?? 'Purchase failed',
          );
        case PurchaseStatus.canceled:
          onPurchaseError?.call('Purchase cancelled');
        case PurchaseStatus.pending:
          // Show loading indicator to user
          break;
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  /// Initiate a premium purchase.
  Future<bool> buyPremium() async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    final response = await _iap.queryProductDetails(
      {premiumProductId, removeAdsProductId},
    );

    if (response.productDetails.isEmpty) {
      debugPrint('No products found');
      return false;
    }

    // Prefer the premium unlock (includes everything)
    final product = response.productDetails.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => response.productDetails.first,
    );

    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore previous purchases (e.g. after reinstall).
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
