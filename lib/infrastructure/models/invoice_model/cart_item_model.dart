import 'package:powersync/sqlite3_common.dart' as sqlite;
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../product_model.dart';

class CartItem {
  final ProductModel product;
  RxDouble quantity;
  RxDouble individualDiscount;
  // RxDouble bundleDiscount;
  RxDouble quantityReturn;

  CartItem({
    required this.product,
    required double quantity,
    double individualDiscount = 0.0,
    double bundleDiscount = 0.0,
    double quantityReturn = 0.0,
  })  : quantity = quantity.obs,
        individualDiscount = individualDiscount.obs,
        // bundleDiscount = bundleDiscount.obs,
        quantityReturn = quantityReturn.obs;

  CartItem.fromJson(Map<String, dynamic> json)
      : product = ProductModel.fromJson(json['product']),
        quantity = ((json['quantity'] is int
                ? json['quantity'].toDouble()
                : json['quantity']) as double)
            .obs,
        individualDiscount = ((json['individual_discount'] is int
                ? json['individual_discount'].toDouble()
                : json['individual_discount']) as double)
            .obs,
        // bundleDiscount = ((json['bundle_discount'] is int
        //         ? json['bundle_discount'].toDouble()
        //         : json['bundle_discount']) as double)
        //     .obs,
        quantityReturn = ((json['Quantity_return'] is int
                ? json['Quantity_return'].toDouble()
                : json['Quantity_return']) as double)
            .obs;

  CartItem.fromRow(sqlite.Row row)
      : product = ProductModel.fromJson(row['product']),
        quantity = ((row['quantity'] is int
                ? row['quantity'].toDouble()
                : row['quantity']) as double)
            .obs,
        individualDiscount = ((row['individual_discount'] is int
                ? row['individual_discount'].toDouble()
                : row['individual_discount']) as double)
            .obs,
        // bundleDiscount = ((row['bundle_discount'] is int
        //         ? row['bundle_discount'].toDouble()
        //         : row['bundle_discount']) as double)
        //     .obs,
        quantityReturn = ((row['Quantity_return'] is int
                ? row['Quantity_return'].toDouble()
                : row['Quantity_return']) as double)
            .obs;

  Map<String, dynamic> toJson() => {
        // final data = <String, dynamic>{};
        'product': product.toJson(),
        'quantity': quantity.value,
        'individual_discount': individualDiscount.value,
        // 'bundle_discount' : bundleDiscount.value,
        'Quantity_return': quantityReturn.value,
        // return data;
      };

  double getPrice(int priceType) {
    switch (priceType) {
      case 1:
        return product.sellPrice1.value;
      case 2:
        return (product.sellPrice2 != null && product.sellPrice2 != 0)
            ? product.sellPrice2!.value
            : product.sellPrice1.value;
      case 3:
        return (product.sellPrice3 != null && product.sellPrice3 != 0)
            ? product.sellPrice3!.value
            : product.sellPrice1.value;
      default:
        return product.sellPrice1.value;
    }
  }

//! Bill
  double getSubBill(int priceType) {
    double price = getPrice(priceType);
    return price * quantity.value;
  }

  double getBill(int priceType) {
    return getSubBill(priceType) - individualDiscount.value;
  }

//! Cost
  double get subCost {
    return product.costPrice.value * quantity.value;
  }

  double get cost {
    return subCost - individualDiscount.value;
  }

//! Return
  double getPurchaseReturn(int priceType) {
    double price = getPrice(priceType);
    return price * quantityReturn.value;
  }

//! Purchase
  double getSubPurchase(int priceType) {
    return getSubBill(priceType) + getPurchaseReturn(priceType);
  }

  double getPurchase(int priceType) {
    return getBill(priceType) + getPurchaseReturn(priceType);
  }

//! Quantity
  double get purchaseQuantity {
    return quantity.value + quantityReturn.value;
  }

  String get quantityDisplay {
    return quantity.value % 1 == 0
        ? quantity.value.toInt().toString()
        : quantity.value.toString().replaceAll('.', ',');
  }

  String get qtyReturnDisplay {
    return quantityReturn.value % 1 == 0
        ? quantityReturn.value.toInt().toString()
        : quantityReturn.value.toString().replaceAll('.', ',');
  }
}
