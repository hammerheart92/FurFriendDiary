import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final premiumProvider = StateProvider<bool>((_) => false);

class PurchaseService {
  static const _productId = String.fromEnvironment('PREMIUM_PRODUCT_ID',
      defaultValue: 'premium_lifetime');
  static final InAppPurchase _iap = InAppPurchase.instance;
  static const _storage = FlutterSecureStorage();

  static Future<void> init(WidgetRef ref) async {
    final cached = await _storage.read(key: 'premium');
    if (cached == 'true') ref.read(premiumProvider.notifier).state = true;
    final available = await _iap.isAvailable();
    if (!available) return;
    // Listen purchases
    _iap.purchaseStream.listen((purchases) {
      for (final p in purchases) {
        if (p.productID == _productId && p.status == PurchaseStatus.purchased) {
          ref.read(premiumProvider.notifier).state = true;
          _storage.write(key: 'premium', value: 'true');
        }
      }
    });
  }

  static Future<List<ProductDetails>> queryProducts() async {
    final response = await _iap.queryProductDetails({_productId});
    return response.productDetails;
  }

  static Future<void> buy(ProductDetails details) async {
    final param = PurchaseParam(productDetails: details);
    await _iap.buyNonConsumable(purchaseParam: param);
  }
}
