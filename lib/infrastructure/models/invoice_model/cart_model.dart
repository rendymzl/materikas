import 'package:powersync/sqlite3_common.dart' as sqlite;
import 'package:get/get.dart';
// import '../../../domain/core/entities/product.dart';
import '../invoice_sales_model.dart';
import '../product_model.dart';
import 'cart_item_model.dart';
import 'invoice_model.dart';

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
  void addItem(ProductModel product) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == product.id);
    if (existingItem != null) {
      existingItem.quantity.value += 1;
    } else {
      items.add(CartItem(
          product: ProductModel.fromJson(product.toJson()), quantity: 1));
    }
  }

  void updateQuantity(String id, double updatedQuantity) {
    final existingItem = items.firstWhereOrNull((item) {
      return item.product.id == id;
    });
    if (existingItem != null) {
      existingItem.quantity.value = updatedQuantity;
    }
  }

  void removeItemStock(ProductModel product, InvoiceModel currentInvoice,
      {bool newReturn = false}) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == product.id);

    final existingCurrentItem = (newReturn
            ? currentInvoice.returnList.value!.items
            : currentInvoice.purchaseList.value.items)
        .firstWhereOrNull((item) => item.product.id == product.id);

    if (existingItem != null) {
      newReturn
          ? existingItem.quantityReturn.value =
              0 - (existingCurrentItem?.quantityReturn.value ?? 0)
          : existingItem.quantity.value =
              0 - (existingCurrentItem?.quantity.value ?? 0);
    } else {
      newReturn
          ? items.add(
              CartItem(
                product: ProductModel.fromJson(product.toJson()),
                quantity: 0,
                quantityReturn:
                    0 - (existingCurrentItem?.quantityReturn.value ?? 0),
              ),
            )
          : items.add(
              CartItem(
                product: ProductModel.fromJson(product.toJson()),
                quantity: 0 - (existingCurrentItem?.quantity.value ?? 0),
                // quantityReturn: existingCurrentItem?.quantityReturn.value ?? 0,
              ),
            );
    }
  }

  void removeItemStockSales(
      ProductModel product, InvoiceSalesModel currentInvoice) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == product.id);

    final existingCurrentItem = (currentInvoice.purchaseList.value.items)
        .firstWhereOrNull((item) => item.product.id == product.id);

    if (existingItem != null) {
      existingItem.quantity.value =
          0 - (existingCurrentItem?.quantity.value ?? 0);
    } else {
      items.add(
        CartItem(
          product: ProductModel.fromJson(product.toJson()),
          quantity: 0 - (existingCurrentItem?.quantity.value ?? 0),
        ),
      );
    }
  }

  void removeItem(String id) {
    items.removeWhere((item) => item.product.id == id);
  }

  void addReturnItem(ProductModel product) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == product.id);
    if (existingItem != null) {
      existingItem.quantityReturn.value += 1;
      existingItem.quantity.value -= 1;
    } else {
      items.add(CartItem(
        product: ProductModel.fromJson(product.toJson()),
        quantity: 0,
        quantityReturn: 1,
      ));
    }
  }

  void substractFromReturnCart(ProductModel product) {
    final existingItem =
        items.firstWhereOrNull((item) => item.product.id == product.id);
    if (existingItem != null) {
      existingItem.quantityReturn.value -= 1;
      existingItem.quantity.value += 1;
    } else {
      items.add(CartItem(
        product: ProductModel.fromJson(product.toJson()),
        quantity: 0,
        quantityReturn: -1,
      ));
    }
  }

  void updateQuantityReturn(String id, double updatedQuantityReturn,
      {bool newReturn = false}) {
    final existingItem = items.firstWhereOrNull((item) {
      return item.product.id == id;
    });
    if (existingItem != null) {
      if (newReturn) {
        existingItem.quantityReturn.value = updatedQuantityReturn;
      } else {
        final totalQuantity =
            existingItem.quantity.value + existingItem.quantityReturn.value;
        if (updatedQuantityReturn > totalQuantity) {
          existingItem.quantity.value = 0;
          existingItem.quantityReturn.value = 0;
          existingItem.quantityReturn.value = totalQuantity;
        } else {
          existingItem.quantity.value = totalQuantity - updatedQuantityReturn;
          existingItem.quantityReturn.value = updatedQuantityReturn;
        }
      }
    }
  }

  void updateQuantityStock(
      ProductModel product, double quantity, InvoiceModel currentInvoice,
      {bool isEditPurchase = false, bool newReturn = false}) {
    final existingItem = items.firstWhereOrNull(
        (item) => item.product.id == product.id);
    final existingCurrentItem = (newReturn
            ? currentInvoice.returnList.value!.items
            : currentInvoice.purchaseList.value.items)
        .firstWhereOrNull(
            (item) => item.product.id == product.id);

    final totalQuantity = (existingCurrentItem?.quantity.value ?? 0) +
        (existingCurrentItem?.quantityReturn.value ?? 0);

    if (existingItem != null) {
      isEditPurchase
          ? existingItem.quantity.value =
              quantity - (existingCurrentItem?.quantity.value ?? 0)
          : existingItem.quantityReturn.value = newReturn
              ? quantity - (existingCurrentItem?.quantityReturn.value ?? 0)
              : quantity > totalQuantity
                  ? totalQuantity -
                      (existingCurrentItem?.quantityReturn.value ?? 0)
                  : quantity - (existingCurrentItem?.quantityReturn.value ?? 0);
    } else {
      isEditPurchase
          ? items.add(
              CartItem(
                product: ProductModel.fromJson(product.toJson()),
                quantity: quantity - (existingCurrentItem?.quantity.value ?? 0),
              ),
            )
          : items.add(
              CartItem(
                product: ProductModel.fromJson(product.toJson()),
                quantity: 0,
                quantityReturn: newReturn
                    ? quantity -
                        (existingCurrentItem?.quantityReturn.value ?? 0)
                    : quantity > totalQuantity
                        ? totalQuantity -
                            (existingCurrentItem?.quantityReturn.value ?? 0)
                        : quantity -
                            (existingCurrentItem?.quantityReturn.value ?? 0),
              ),
            );
    }
  }

  void updateQuantityStockSales(
      ProductModel product, double quantity, InvoiceSalesModel currentInvoice) {
    final existingItem = items.firstWhereOrNull(
        (item) => item.product.id == product.id);
    final existingCurrentItem = (currentInvoice.purchaseList.value.items)
        .firstWhereOrNull(
            (item) => item.product.id == product.id);

    if (existingItem != null) {
      existingItem.quantity.value =
          quantity - (existingCurrentItem?.quantity.value ?? 0);
    } else {
      items.add(
        CartItem(
          product: ProductModel.fromJson(product.toJson()),
          quantity: quantity - (existingCurrentItem?.quantity.value ?? 0),
        ),
      );
    }
  }

  // void updateNewQuantityStock(
  //     ProductModel product, double quantity, InvoiceModel currentInvoice) {
  //   final existingItem = items.firstWhereOrNull(
  //       (item) => item.product.id == product.id);
  //   final existingCurrentItem = (newReturn
  //           ? currentInvoice.returnList.value!.items
  //           : currentInvoice.purchaseList.value.items)
  //       .firstWhereOrNull(
  //           (item) => item.product.id == product.id);

  //   final totalQuantity = (existingCurrentItem?.quantity.value ?? 0) +
  //       (existingCurrentItem?.quantityReturn.value ?? 0);

  //   if (existingItem != null) {
  //     existingItem.quantityReturn.value = newReturn
  //         ? quantity
  //         : quantity > totalQuantity
  //             ? totalQuantity
  //             : quantity - (existingCurrentItem?.quantityReturn.value ?? 0);
  //   } else {
  //     items.add(CartItem(
  //         product: ProductModel.fromJson(product.toJson()),
  //         quantity: 0,
  //         quantityReturn: newReturn
  //             ? quantity
  //             : quantity > totalQuantity
  //                 ? totalQuantity
  //                 : quantity));
  //   }
  // }

  void updateDiscount(String id, double updatedDiscount) {
    final existingItem =
        items.firstWhere((item) => item.product.id == id);
    existingItem.individualDiscount.value = updatedDiscount;
  }
}
