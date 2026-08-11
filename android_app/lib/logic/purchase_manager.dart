import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Poort van `PurchaseManager.swift`: één eenmalige (non-consumable) aankoop die
/// "Premium" ontgrendelt — geen abonnement. Gebruikt de `in_app_purchase`-plugin
/// (Google Play Billing) en cachet de status lokaal, zodat gating meteen bij
/// app-start klopt; bij start wordt de entitlement via `restorePurchases`
/// geverifieerd.
class PurchaseManager extends ChangeNotifier {
  PurchaseManager._();
  static final PurchaseManager instance = PurchaseManager._();

  /// Moet exact overeenkomen met het in-app product dat in de Play Console
  /// wordt aangemaakt (managed product / eenmalige aankoop).
  static const String premiumProductId = 'premium_unlock';
  static const String _prefKey = 'wwIsPremiumUnlocked';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _isPremiumUnlocked = false;
  bool get isPremiumUnlocked => _isPremiumUnlocked;

  bool _storeAvailable = false;
  bool get storeAvailable => _storeAvailable;

  bool _isLoadingProduct = true;
  bool get isLoadingProduct => _isLoadingProduct;

  ProductDetails? _product;
  ProductDetails? get product => _product;

  /// Weergaveprijs uit de store (bv. "€ 3,99"), of null als het product niet laadt.
  String? get priceLabel => _product?.price;

  String? purchaseErrorMessage;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumUnlocked = prefs.getBool(_prefKey) ?? false;
    notifyListeners();

    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      _isLoadingProduct = false;
      notifyListeners();
      return;
    }

    _sub = _iap.purchaseStream.listen(_onPurchaseUpdates, onError: (_) {});

    await _loadProduct();
    // Herstelt een bestaande aankoop stil via de purchaseStream.
    await _iap.restorePurchases();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    _isLoadingProduct = true;
    notifyListeners();
    try {
      final resp = await _iap.queryProductDetails({premiumProductId});
      _product = resp.productDetails.isNotEmpty ? resp.productDetails.first : null;
    } catch (_) {
      _product = null;
      purchaseErrorMessage = 'Kon productinformatie niet laden. Probeer het later opnieuw.';
    }
    _isLoadingProduct = false;
    notifyListeners();
  }

  Future<void> buyPremium() async {
    final product = _product;
    if (product == null) return;
    purchaseErrorMessage = null;
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  Future<void> restore() async {
    purchaseErrorMessage = null;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == premiumProductId) {
            await _setUnlocked(true);
          }
        case PurchaseStatus.error:
          purchaseErrorMessage = 'De aankoop is niet gelukt. Probeer het opnieuw.';
          notifyListeners();
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setUnlocked(bool value) async {
    _isPremiumUnlocked = value;
    (await SharedPreferences.getInstance()).setBool(_prefKey, value);
    notifyListeners();
  }
}
