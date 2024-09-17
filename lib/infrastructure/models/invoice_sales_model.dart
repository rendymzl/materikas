import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import 'invoice_model/cart_model.dart';
import 'payment_model.dart';
import 'sales_model.dart';

class InvoiceSalesModel {
  String? id;
  String? storeId;
  String? invoiceId;
  late Rx<DateTime?> createdAt;
  late Rx<SalesModel?> sales;
  late Rx<Cart> purchaseList;
  late RxDouble discount;
  late RxDouble tax;
  late RxList<PaymentModel> payments;
  late RxDouble debtAmount;
  late RxBool isDebtPaid;

  InvoiceSalesModel({
    this.id,
    this.storeId,
    this.invoiceId,
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
  })  : createdAt = Rx<DateTime?>(createdAt),
        sales = Rx<SalesModel?>(sales),
        purchaseList = Rx<Cart>(purchaseList),
        discount = RxDouble(discount),
        tax = RxDouble(tax),
        payments = RxList<PaymentModel>(payments ?? []),
        debtAmount = RxDouble(debtAmount),
        isDebtPaid = RxBool(isDebtPaid);

  InvoiceSalesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    invoiceId = json['invoice_id'];
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
  }

  InvoiceSalesModel.fromRow(sqlite.Row row)
      : id = row['id'],
        storeId = row['store_id'],
        invoiceId = row['invoice_id'],
        createdAt = Rx<DateTime?>(DateTime.parse(row['created_at']).toLocal()),
        sales = Rx<SalesModel?>(SalesModel.fromJson(row['sales'])),
        purchaseList = Rx<Cart>(Cart.fromJson(row['purchase_list'])),
        discount = RxDouble(row['discount'].toDouble()),
        tax = RxDouble(row['tax'].toDouble()),
        payments = RxList<PaymentModel>((row['payments'] as List)
            .map((i) => PaymentModel.fromJson(i))
            .toList()),
        debtAmount = RxDouble(row['debt_amount'].toDouble()),
        isDebtPaid = RxBool(row['is_debt_paid']);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['store_id'] = storeId;
    data['invoice_id'] = invoiceId;
    data['created_at'] = createdAt.value?.toIso8601String();
    data['sales'] = sales.value?.toJson();
    data['purchase_list'] = purchaseList.value.toJson();
    data['discount'] = discount.value;
    data['tax'] = tax.value;
    data['payments'] = payments.map((item) => item.toJson()).toList();
    data['debt_amount'] = debtAmount.value;
    data['is_debt_paid'] = isDebtPaid.value;
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
    payments.add(PaymentModel(
        method: method,
        amountPaid: amount,
        remain: totalCost - (totalPaid + amount),
        finalAmountPaid: (totalPaid + amount) > totalCost
            ? amount + (totalCost - (totalPaid + amount))
            : (totalPaid + amount),
        date: date));
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
      if (payment.method != null &&
          (selectedDate == null ||
              (payment.date?.year == selectedDate.year &&
                  payment.date?.month == selectedDate.month &&
                  payment.date?.day == selectedDate.day))) {
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
