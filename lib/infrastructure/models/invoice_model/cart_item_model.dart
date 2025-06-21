import 'package:powersync/sqlite3_common.dart' as sqlite;
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../product_model.dart';

class CartItem {
  ProductModel product;
  RxDouble quantity;
  RxDouble individualDiscount;
  RxDouble quantityReturn;
  Rx<DateTime?> returnDate;
  String? invoiceId;

  CartItem({
    required this.product,
    required double quantity,
    double individualDiscount = 0.0,
    double quantityReturn = 0.0,
    DateTime? returnDate,
    this.invoiceId,
  })  : quantity = quantity.obs,
        individualDiscount = individualDiscount.obs,
        quantityReturn = quantityReturn.obs,
        returnDate = returnDate.obs;

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
        quantityReturn = ((json['Quantity_return'] is int
                ? json['Quantity_return'].toDouble()
                : json['Quantity_return']) as double)
            .obs,
        returnDate = (json['return_date'] != null
                ? DateTime.parse(json['return_date']).toLocal()
                : null)
            .obs,
        invoiceId = json['invoice_id'];

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
        quantityReturn = ((row['Quantity_return'] is int
                ? row['Quantity_return'].toDouble()
                : row['Quantity_return']) as double)
            .obs,
        returnDate = (row['return_date'] != null
                ? DateTime.parse(row['return_date']).toLocal()
                : null)
            .obs,
        invoiceId = row['invoice_id'];

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity.value,
        'individual_discount': individualDiscount.value,
        'Quantity_return': quantityReturn.value,
        'return_date': returnDate.value?.toIso8601String(),
        'invoice_id': invoiceId,
      };

  double getPrice(int priceType) {
    switch (priceType) {
      case 1:
        return product.sellPrice1.value;
      case 2:
        return (product.sellPrice2 != null && product.sellPrice2 != 0.0.obs)
            ? product.sellPrice2!.value
            : product.sellPrice1.value;
      case 3:
        return (product.sellPrice3 != null && product.sellPrice3 != 0.0.obs)
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
  double getReturn(int priceType) {
    double price = getPrice(priceType);
    return price * quantityReturn.value;
  }

//! Purchase
  double getSubPurchase(int priceType) {
    return getSubBill(priceType) + getReturn(priceType);
  }

  double getPurchase(int priceType) {
    return getBill(priceType) + getReturn(priceType);
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

  String get quantityReturnDisplay {
    return quantityReturn.value % 1 == 0
        ? quantityReturn.value.toInt().toString()
        : quantityReturn.value.toString().replaceAll('.', ',');
  }

  String get quantityTotalDisplay {
    double quantityTotal = quantity.value + quantityReturn.value;
    return quantityTotal % 1 == 0
        ? quantityTotal.toInt().toString()
        : quantityTotal.toString().replaceAll('.', ',');
  }
}
