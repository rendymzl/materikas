import 'dart:convert';

import 'package:get/get.dart';

import 'invoice_model/cart_item_model.dart';
import 'invoice_model/cart_model.dart';
import 'product_model.dart';

class Chart {
  DateTime date;
  String dateDisplay;

  int totalInvoice;
  double totalBill;
  double totalCost;
  double totalDiscount;
  double totalCash;
  double totalTransfer;
  double totalDebtCash;
  double totalDebtTransfer;
  double purchaseReturn;
  double additionalReturn;
  double returnFee;
  double operatingCostCash;
  double operatingCostTransfer;
  double totalSalesCash;
  double totalSalesTransfer;

  Chart({
    required this.date,
    required this.dateDisplay,
    this.totalInvoice = 0,
    this.totalBill = 0.0,
    this.totalCost = 0.0,
    this.totalDiscount = 0.0,
    this.totalCash = 0.0,
    this.totalTransfer = 0.0,
    this.totalDebtCash = 0.0,
    this.totalDebtTransfer = 0.0,
    this.purchaseReturn = 0.0,
    this.additionalReturn = 0.0,
    this.returnFee = 0.0,
    this.operatingCostCash = 0.0,
    this.operatingCostTransfer = 0.0,
    this.totalSalesCash = 0.0,
    this.totalSalesTransfer = 0.0,
  });

  factory Chart.fromJson(Map<String, dynamic> json) {
    DateTime date = DateTime.parse(json['created_at']);
    // int totalInvoice = 0;
    // RxInt priceType = RxInt(1);
    // double returnFee = 0.0;
    int totalInvoice = json['total_invoices']?.toInt() ?? 0;
    print('debug price_type ${json['price_type']}');
    // List priceTypeList = json['price_type'] as List<dynamic>;
    RxInt priceType = RxInt(1);
    double returnFee = json['return_fee']?.toDouble() ?? 0.0;
    Rx<Cart> purchaseList = Cart(items: <CartItem>[].obs).obs;
    RxList<CartItem> returnList = <CartItem>[].obs;
    // Rx<Cart> purchaseListSales = Cart(items: <CartItem>[].obs).obs;
    double totalBill = 0;
    double totalCost = 0;
    double fault = 0;
    double totalDiscount = 0;
    double purchaseReturn = 0;
    double totalCash = json['total_cash']?.toDouble() ?? 0.0;
    double totalTransfer = json['total_transfer']?.toDouble() ?? 0.0;
    double totalDebtCash = json['total_debt_cash']?.toDouble() ?? 0.0;
    double totalDebtTransfer = json['total_debt_transfer']?.toDouble() ?? 0.0;
    double totalOperatingCost = json['total_operating_cost']?.toDouble() ?? 0.0;
    double totalSalesCash = json['total_sales_cash']?.toDouble() ?? 0.0;
    double totalSalesTransfer = json['total_sales_transfer']?.toDouble() ?? 0.0;

    if (json['purchase_list_json'] != null) {
      print('debug purchase_list ${json['purchase_list_json']}');
      if (json['purchase_list_json'] is String) {
        print('debug purchase_list is string');
        final decodedPurchaseList = jsonDecode(json['purchase_list_json']);

        if (decodedPurchaseList is String) {
          print('debug purchase_list secont is string');
        } else {
          print('debug purchase_list secont is not string');
        }

        final listCart = decodedPurchaseList is String
            ? jsonDecode(decodedPurchaseList) as List<dynamic>
            : decodedPurchaseList as List<dynamic>;
        if (date.day == DateTime.now().day) {
          print('debug purchase_list lenght ${date}');
          print('debug purchase_list lenght ${listCart.length}');
        }
        for (var cartJson in listCart) {
          final cart = Cart.fromJson(cartJson['purchase_list'] is String
              ? jsonDecode(cartJson['purchase_list'])
              : cartJson['purchase_list'] as Map<String, dynamic>);
          priceType = RxInt(int.parse(cartJson['price_type'] ?? '1'));
          if (cart.items.isNotEmpty) {
            for (var purchase in cart.items) {
              if (
                  purchase.product.costPrice.value >
                      purchase.product.sellPrice1.value) {
                print(
                    'debug purchase_list lenght ---');
                print(
                    'debug purchase_list lenght name ${purchase.product.productName}');
                print(
                    'debug purchase_list lenght cost ${purchase.product.costPrice.value}');
                print(
                    'debug purchase_list lenght sell ${purchase.product.sellPrice1.value}');
              }
              fault += (purchase.subCost > purchase.getSubBill(priceType.value)
                  ? 1
                  : 0);
              totalBill += purchase.getSubBill(priceType.value);
              totalCost += purchase.subCost;
              totalDiscount += purchase.individualDiscount.value;
            }
            totalDiscount += cart.bundleDiscount.value;
          }
        }
      } else if (json['purchase_list_json'] is List) {
        print('debug purchase_list is list');
        for (var cartJson in json['purchase_list_json']) {
          final cart = Cart.fromJson(jsonDecode(cartJson));
          if (cart.items.isNotEmpty) {
            for (var purchase in cart.items) {
              fault += (purchase.subCost > purchase.getSubBill(priceType.value)
                  ? 1
                  : 0);
              totalBill += purchase.getSubBill(priceType.value);
              totalCost += purchase.subCost;
              totalDiscount += purchase.individualDiscount.value;
            }
            totalDiscount += cart.bundleDiscount.value;
          }
        }
      }
      print('debug totalDiscount $totalDiscount');
      print('debug fault $fault');
      print('debug fault totalBill $totalBill');
      print('debug fault totalCost $totalCost');
    }

    if (json['return_items'] != null) {
      if (json['return_items'] is String) {
        final decodedReturnItems = jsonDecode(json['return_items']);

        final returnItemsList = decodedReturnItems is String
            ? jsonDecode(decodedReturnItems) as List<dynamic>
            : decodedReturnItems as List<dynamic>;

        print('debug returnItem $returnItemsList');
        print('debug returnItem lenght ${returnItemsList.length}');
        returnList = RxList<CartItem>(
          returnItemsList.map((item) {
            final product =
                ProductModel.fromJson(jsonDecode(item['product'] as String));
            final qtyReturn = double.parse(item['Quantity_return'] ?? '0.0');
            returnFee = double.parse(item['return_fee'] ?? '0.0');
            final cartItem = CartItem(
              product: product,
              quantity: 0,
              quantityReturn: qtyReturn,
            );
            print('debug returnItem ${product.getPrice(priceType.value)}');
            print('debug returnItem ${returnFee}');
            print('debug returnItem ------');
            return cartItem;
          }).toList(),
        );
      } else {
        returnList = RxList<CartItem>(
          (json['return_items'] as List<dynamic>).map((item) {
            final product =
                ProductModel.fromJson(jsonDecode(item['product'] as String));
            final qtyReturn = double.parse(item['Quantity_return'] ?? '0.0');
            returnFee = double.parse(item['return_fee'] ?? '0.0');
            final cartItem = CartItem(
              product: product,
              quantity: 0,
              quantityReturn: qtyReturn,
            );
            return cartItem;
          }).toList(),
        );
      }

      if (returnList.isNotEmpty) {
        for (var item in returnList) {
          purchaseReturn += item.getReturn(priceType.value);
        }
      }
    }

    print('debug returnFee $returnFee');

    // if (json['purchase_list_sales'] is String) {
    //   final decodedPurchaseList = jsonDecode(json['purchase_list_sales']);
    //   purchaseListSales = Rx<Cart>(
    //     Cart.fromJson(
    //       decodedPurchaseList is String
    //           ? jsonDecode(decodedPurchaseList) as Map<String, dynamic>
    //           : decodedPurchaseList as Map<String, dynamic>,
    //     ),
    //   );
    // } else if (json['purchase_list_sales'] is Map<String, dynamic>) {
    //   purchaseListSales = Rx<Cart>(Cart.fromJson(json['purchase_list_sales']));
    // }

    // if (purchaseListSales.value.items.isNotEmpty) {
    //   for (var purchase in purchaseListSales.value.items) {
    //     totalBill += purchase.getBill(priceType.value);
    //     totalBill += purchase.getBill(priceType.value);
    //     totalCost += purchase.cost;
    //     totalDiscount += purchase.individualDiscount.value;
    //   }
    //   totalDiscount += purchaseList.value.bundleDiscount.value;
    // }

    return Chart(
      date: date,
      dateDisplay: '',
      totalInvoice: totalInvoice,
      totalBill: totalBill,
      totalCost: totalCost,
      totalDiscount: totalDiscount,
      totalCash: totalCash,
      totalTransfer: totalTransfer,
      totalDebtCash: totalDebtCash,
      totalDebtTransfer: totalDebtTransfer,
      purchaseReturn: purchaseReturn,
      additionalReturn: 0.0,
      returnFee: returnFee,
      operatingCostCash: totalOperatingCost,
      operatingCostTransfer: 0.0,
      totalSalesCash: totalSalesCash,
      totalSalesTransfer: totalSalesTransfer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': date.toIso8601String(),
      'total_invoices': totalInvoice,
      'total_bill': totalBill,
      'total_cost': totalCost,
      'total_discount': totalDiscount,
      'total_cash': totalCash,
      'total_transfer': totalTransfer,
      'total_debt_cash': totalDebtCash,
      'total_debt_transfer': totalDebtTransfer,
      'purchase_return': purchaseReturn,
      'additional_return': additionalReturn,
      'return_fee': returnFee,
      'operating_cost_cash': operatingCostCash,
      'operating_cost_transfer': operatingCostTransfer,
      'total_sales_cash': totalSalesCash,
      'total_sales_transfer': totalSalesTransfer,
    };
  }

//! invoice report
  double get finalBill => (totalBill) - (totalDiscount);

  double get totalReturn => (purchaseReturn + additionalReturn);

  double get finalReturn => totalReturn - (returnFee);

  double get grossProfit => finalBill - (totalCost) - finalReturn;

  double get totalOperatingCost => operatingCostCash - operatingCostTransfer;

  double get cleanProfit => grossProfit - (totalOperatingCost);

//! money report
//! INCOME
  double get income => (totalCash) + (totalTransfer);
  double get incomeDebt => (totalDebtCash) + (totalDebtTransfer);

  double get incomeCash => (totalCash) + (totalDebtCash);
  double get incomeTransfer => (totalTransfer) + (totalDebtTransfer);

  double get finalIncome => (income) + (incomeDebt);
  double get notYetPaid => finalBill - income;

//! OUTCOME
  double get outcome => (totalSalesCash) + (totalSalesTransfer) + finalReturn;
  double get outcomeCash =>
      (totalSalesCash) + (operatingCostCash) + finalReturn;
  double get outcomeTransfer => (totalSalesTransfer) + (operatingCostTransfer);
  double get finalOutcome => (outcome) + (totalOperatingCost);

  double get resultIncomeOutcome => finalIncome - finalOutcome;
  double get finalIncomeCash => incomeCash - outcomeCash;
  double get finalIncomeTransfer =>
      incomeTransfer + operatingCostTransfer - totalSalesTransfer;

//! ACRA DEDICATED
  double get finalIncomeCashArca => incomeCash - outcomeCashArca;
  double get finalIncomeTransferArca => incomeTransfer - outcomeTransferArca;

  double get outcomeCashArca => (totalSalesCash) + (operatingCostCash);
  double get outcomeTransferArca =>
      (totalSalesTransfer) + (operatingCostTransfer);
  double get finalOutcomeArca => (outcomeCashArca) + (outcomeTransferArca);

  double get resultIncomeOutcomeArca => finalIncome - finalOutcomeArca;
}
