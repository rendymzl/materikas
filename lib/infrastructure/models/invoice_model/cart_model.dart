import 'package:powersync/sqlite3_common.dart' as sqlite;
import 'package:get/get.dart';
import 'cart_item_model.dart';

class Cart {
  var items = <CartItem>[].obs;
  var bundleDiscount = 0.0.obs;

  Cart({required this.items});

  Cart.fromJson(Map<String, dynamic> json) {
    items.value =
        (json['items'] as List).map((i) => CartItem.fromJson(i)).toList();
    bundleDiscount.value = json['bundle_discount'] ?? 0.0;
  }

  Cart.fromRow(sqlite.Row row) {
    items.value =
        (row['items'] as List).map((i) => CartItem.fromRow(i)).toList();
    bundleDiscount.value = row['bundle_discount'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['items'] = items.map((item) => item.toJson()).toList();
    data['bundle_discount'] = bundleDiscount.value;
    return data;
  }

//! Bill
  double getSubtotalBill(int priceType) {
    double subtotal =
        items.fold(0, (sum, item) => sum + item.getSubBill(priceType));

    return subtotal;
  }

  double getTotalBill(int priceType) {
    double total =
        items.fold(0.0, (sum, item) => sum + item.getBill(priceType)) -
            bundleDiscount.value;

    return total;
  }

//! Cost
  double get subtotalCost {
    double costPrice = items.fold(0.0, (sum, item) => sum + item.subCost);

    return costPrice;
  }

  double get totalCost {
    double costPrice = items.fold(0.0, (sum, item) => sum + item.cost);

    return costPrice;
  }

//! Return
  double getTotalReturn(int priceType) {
    double totalReturn =
        items.fold(0.0, (sum, item) => sum + item.getReturn(priceType));

    return totalReturn;
  }

  //! Purchase
  double getSubtotalPurchase(int priceType) {
    double purchasePrice =
        items.fold(0.0, (sum, item) => sum + item.getSubPurchase(priceType));

    return purchasePrice;
  }

  double getTotalPurchase(int priceType) {
    double purchasePrice =
        items.fold(0.0, (sum, item) => sum + item.getPurchase(priceType)) -
            bundleDiscount.value;

    return purchasePrice;
  }

//! Quantity
  double get totalQuantity {
    double totalQuantity =
        items.fold(0.0, (sum, item) => sum + item.quantity.value);

    return totalQuantity;
  }

  double get totalQuantityReturn {
    double quantityReturn =
        items.fold(0.0, (sum, item) => sum + item.quantityReturn.value);

    return quantityReturn;
  }

  double get totalQuantityPurchase {
    double totalQuantityReturn =
        items.fold(0.0, (sum, item) => sum + item.purchaseQuantity);

    return totalQuantityReturn;
  }

//! Discount
  double get totalIndividualDiscount {
    return items.fold(0.0, (sum, item) => sum + item.individualDiscount.value);
  }

//! func
  void addItem(CartItem newItem) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == newItem.product.id);
    if (existingItem != null) {
      existingItem.quantity.value += newItem.quantity.value;
    } else {
      items.add(newItem);
    }
  }

  void addReturnItem(CartItem newItem) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == newItem.product.id);
    if (existingItem != null) {
      existingItem.quantityReturn.value += newItem.quantityReturn.value;
    } else {
      items.add(newItem);
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, double updatedQuantity) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.quantity.value = updatedQuantity;
  }

  void updateQuantityReturn(String productId, double updatedQuantityReturn) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.quantityReturn.value = updatedQuantityReturn;
  }

  void updateDiscount(String productId, double updatedDiscount) {
    final existingItem =
        items.firstWhere((item) => item.product.id == productId);
    existingItem.individualDiscount.value = updatedDiscount;
  }
}
