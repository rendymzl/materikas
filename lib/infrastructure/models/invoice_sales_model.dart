import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import 'invoice_model/cart_model.dart';
import 'payment_model.dart';
import 'sales_model.dart';

class InvoiceSalesModel {
  String? id;
  String? storeId;
  String? invoiceNumber;
  late Rx<String?> invoiceName;
  late Rx<DateTime?> createdAt;
  late Rx<SalesModel?> sales;
  late Rx<Cart> purchaseList;
  late RxDouble discount;
  late RxDouble tax;
  late RxList<PaymentModel> payments;
  late RxDouble debtAmount;
  late RxBool isDebtPaid;
  late Rx<DateTime?> removeAt;
  late RxBool purchaseOrder;

  InvoiceSalesModel({
    this.id,
    this.storeId,
    this.invoiceNumber,
    String? invoiceName,
    DateTime? createdAt,
    SalesModel? sales,
    required Cart purchaseList,
    Cart? returnList,
    Cart? afterReturnList,
    required int priceType,
    double discount = 0,
    double tax = 0,
    double returnFee = 0,
    List<PaymentModel>? payments,
    double debtAmount = 0,
    bool isDebtPaid = false,
    DateTime? removeAt,
    bool purchaseOrder = false,
  })  : createdAt = Rx<DateTime?>(createdAt),
        sales = Rx<SalesModel?>(sales),
        purchaseList = Rx<Cart>(purchaseList),
        discount = RxDouble(discount),
        tax = RxDouble(tax),
        payments = RxList<PaymentModel>(payments ?? []),
        debtAmount = RxDouble(debtAmount),
        isDebtPaid = RxBool(isDebtPaid),
        removeAt = Rx<DateTime?>(removeAt),
        purchaseOrder = RxBool(purchaseOrder),
        invoiceName = Rx<String?>(invoiceName);

  InvoiceSalesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    invoiceNumber = json['invoice_number'];
    invoiceName = Rx<String?>(json['invoice_name']);
    createdAt = Rx<DateTime?>(DateTime.parse(json['created_at']).toLocal());
    // Handling customer field
    if (json['sales'] != null) {
      final decodedSales =
          json['sales'] is String ? jsonDecode(json['sales']) : json['sales'];
      sales = Rx<SalesModel?>(
        SalesModel.fromJson(
          decodedSales is String
              ? jsonDecode(decodedSales) as Map<String, dynamic>
              : decodedSales as Map<String, dynamic>,
        ),
      );
    }
    // Handling purchaseList field
    if (json['purchase_list'] is String) {
      final decodedPurchaseList = jsonDecode(json['purchase_list']);
      purchaseList = Rx<Cart>(
        Cart.fromJson(
          decodedPurchaseList is String
              ? jsonDecode(decodedPurchaseList) as Map<String, dynamic>
              : decodedPurchaseList as Map<String, dynamic>,
        ),
      );
    } else if (json['purchase_list'] is Map<String, dynamic>) {
      purchaseList = Rx<Cart>(Cart.fromJson(json['purchase_list']));
    }
    discount = RxDouble(json['discount'].toDouble());
    tax = RxDouble(json['tax'].toDouble());
    // Handling payments field
    if (json['payments'] != null) {
      // Check if payments is a JSON string
      final dynamic paymentData = json['payments'] is String
          ? jsonDecode(json['payments'])
          : json['payments'];

      // Ensure paymentData is a list
      if (paymentData is List) {
        payments = RxList<PaymentModel>(
          paymentData
              .map((i) => PaymentModel.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        // Handle the case where paymentData is not a list
        payments = RxList<PaymentModel>(
          (jsonDecode(paymentData) as List)
              .map((i) => PaymentModel.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      }
    } else {
      payments = RxList<PaymentModel>();
    }
    debtAmount = RxDouble(json['debt_amount'].toDouble());
    isDebtPaid = RxBool(json['is_debt_paid'] == 1);
    removeAt = Rx<DateTime?>(json['remove_at'] != null
        ? DateTime.parse(json['remove_at']).toLocal()
        : null);
    // print('purchaseOrder aaa  ${json['purchase_order']}');
    purchaseOrder = RxBool(json['purchase_order'] is bool
        ? json['purchase_order']
        : json['purchase_order'] == 1);
    // print('purchaseOrder bool ${purchaseOrder.value}');
  }

  InvoiceSalesModel.fromRow(sqlite.Row row)
      : id = row['id'],
        storeId = row['store_id'],
        invoiceNumber = row['invoice_number'],
        invoiceName = Rx<String?>(row['invoice_name']),
        createdAt = Rx<DateTime?>(DateTime.parse(row['created_at']).toLocal()),
        sales = Rx<SalesModel?>(SalesModel.fromJson(row['sales'])),
        purchaseList = Rx<Cart>(Cart.fromJson(row['purchase_list'])),
        discount = RxDouble(row['discount'].toDouble()),
        tax = RxDouble(row['tax'].toDouble()),
        payments = RxList<PaymentModel>((row['payments'] as List)
            .map((i) => PaymentModel.fromJson(i))
            .toList()),
        debtAmount = RxDouble(row['debt_amount'].toDouble()),
        isDebtPaid = RxBool(row['is_debt_paid']),
        removeAt = Rx<DateTime?>(row['remove_at'] != null
            ? DateTime.parse(row['remove_at']).toLocal()
            : null),
        purchaseOrder = RxBool(row['purchase_order']);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['store_id'] = storeId;
    data['invoice_number'] = invoiceNumber;
    data['invoice_name'] = invoiceName.value;
    data['created_at'] = createdAt.value?.toIso8601String();
    data['sales'] = sales.value?.toJson();
    data['purchase_list'] = purchaseList.value.toJson();
    data['discount'] = discount.value;
    data['tax'] = tax.value;
    data['payments'] = payments.map((item) => item.toJson()).toList();
    data['debt_amount'] = debtAmount.value;
    data['is_debt_paid'] = isDebtPaid.value;
    data['remove_at'] = removeAt.value?.toIso8601String();
    data['purchase_order'] = purchaseOrder.value;
    return data;
  }

  double get subtotalCost {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + item.subCost);
  }

  double get totalIndividualDiscount {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + (item.individualDiscount.value));
  }

  double get totalDiscount {
    return totalIndividualDiscount;
  }

  double get totalTax {
    return subtotalCost * (tax.value ~/ 100);
  }

  double get totalCost {
    return subtotalCost - totalDiscount + totalTax;
  }

  double get totalPaid {
    return payments.fold(0, (prev, payment) => prev + payment.amountPaid);
  }

  double get remainingDebt {
    return totalCost - totalPaid;
  }

  void addPayment(double amount, {String? method, DateTime? date}) {
    double finalAmountPaid = amount;
    double remaining = totalCost - totalPaid;

    if (finalAmountPaid > remaining) {
      finalAmountPaid = remaining;
    }

    payments.add(PaymentModel(
      storeId: storeId,
      method: method,
      amountPaid: amount,
      remain: totalCost - (totalPaid + amount),
      finalAmountPaid: finalAmountPaid,
      date: date,
    ));
    updateIsDebtPaid();
  }

  void removePayment(PaymentModel paymentTransaction) {
    payments.remove(paymentTransaction);
    updateIsDebtPaid();
  }

  void updateIsDebtPaid() {
    debtAmount.value = totalCost - totalPaid;
    isDebtPaid.value = remainingDebt <= 0;
  }

  double totalPaidByIndex(int index) {
    var sublist = payments.sublist(0, index + 1);

    double total = sublist
        .map((payment) => payment.finalAmountPaid)
        .reduce((a, b) => a + b);
    return total;
  }

  // Map<String, double> totalPaymentsByMethod() {
  //   Map<String, double> totals = {};
  //   for (var payment in payments) {
  //     if (payment.method != null) {
  //       if (!totals.containsKey(payment.method)) {
  //         totals[payment.method!] = 0;
  //       }
  //       totals[payment.method!] = totals[payment.method!]! + payment.amountPaid;
  //     }
  //   }
  //   return totals;
  // }

  // double getTotalByMethod(String method) {
  //   return totalPaymentsByMethod()[method] ?? 0;
  // }

  Map<String, double> totalPaymentsByMethod({DateTime? selectedDate}) {
    Map<String, double> totals = {};
    for (var payment in payments) {
      if (payment.method != null) {
        if (!totals.containsKey(payment.method)) {
          totals[payment.method!] = 0;
        }
        double result = totals[payment.method!]! + payment.amountPaid;
        totals[payment.method!] = result <= totalCost ? result : totalCost;
      }
    }
    return totals;
  }

  double getTotalByMethod(String method, {DateTime? selectedDate}) {
    return totalPaymentsByMethod(selectedDate: selectedDate)[method] ?? 0;
  }
}
