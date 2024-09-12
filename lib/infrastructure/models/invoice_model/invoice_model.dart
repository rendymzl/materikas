import 'dart:convert';

import 'package:powersync/sqlite3_common.dart' as sqlite;
import 'package:get/get.dart';

import '../account_model.dart';
import '../customer_model.dart';
import '../payment_model.dart';
import 'cart_model.dart';

class OtherCost {
  String name;
  double amount;

  OtherCost({
    required this.name,
    required this.amount,
  });

  OtherCost.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        amount = json['amount'].toDouble();

  OtherCost.fromRow(sqlite.Row row)
      : name = row['name'],
        amount = row['amount'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['amount'] = amount;
    return data;
  }
}

class InvoiceModel {
  String? id;
  String? storeId;
  String? invoiceId;
  late Rx<AccountModel> account;
  late Rx<DateTime?> createdAt;
  late Rx<CustomerModel?> customer;
  late Rx<Cart> purchaseList;
  late Rx<Cart?> returnList = Rx<Cart?>(null);
  late Rx<Cart?> afterReturnList = Rx<Cart?>(null);
  late RxInt priceType;
  late RxDouble discount;
  late RxDouble tax;
  late RxDouble returnFee;
  late RxList<PaymentModel> payments;
  late RxDouble debtAmount;
  late RxBool isDebtPaid;
  late RxList<OtherCost> otherCosts;

  InvoiceModel({
    this.id,
    this.storeId,
    this.invoiceId,
    required AccountModel account,
    DateTime? createdAt,
    CustomerModel? customer,
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
    List<OtherCost>? otherCosts,
  })  : account = Rx<AccountModel>(account),
        createdAt = Rx<DateTime?>(createdAt),
        customer = Rx<CustomerModel?>(customer),
        purchaseList = Rx<Cart>(purchaseList),
        returnList = Rx<Cart?>(returnList),
        afterReturnList = Rx<Cart?>(afterReturnList),
        priceType = RxInt(priceType),
        discount = RxDouble(discount),
        tax = RxDouble(tax),
        returnFee = RxDouble(returnFee),
        payments = RxList<PaymentModel>(payments ?? []),
        // change = RxDouble(change),
        debtAmount = RxDouble(debtAmount),
        isDebtPaid = RxBool(isDebtPaid),
        otherCosts = RxList<OtherCost>(otherCosts ?? []);

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    // Handling account field
    if (json['account'] is String) {
      final decodedAccount = jsonDecode(json['account']);
      account = Rx<AccountModel>(AccountModel.fromJson(
        decodedAccount is String
            ? jsonDecode(decodedAccount) as Map<String, dynamic>
            : decodedAccount as Map<String, dynamic>,
      ));
    } else if (json['account'] is Map<String, dynamic>) {
      account = Rx<AccountModel>(AccountModel.fromJson(json['account']));
    }

    id = json['id'];
    storeId = json['store_id'];
    invoiceId = json['invoice_id'];

    // Handling createdAt field
    createdAt = Rx<DateTime?>(
      json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
    );

    // Handling customer field
    if (json['customer'] != null) {
      final decodedCustomer = json['customer'] is String
          ? jsonDecode(json['customer'])
          : json['customer'];
      customer = Rx<CustomerModel?>(
        CustomerModel.fromJson(
          decodedCustomer is String
              ? jsonDecode(decodedCustomer) as Map<String, dynamic>
              : decodedCustomer as Map<String, dynamic>,
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

    // Handling returnList field
    if (json['return_list'] != null) {
      final decodedReturnList = json['return_list'] is String
          ? jsonDecode(json['return_list'])
          : json['return_list'];
      returnList = Rx<Cart?>(
        Cart.fromJson(
          decodedReturnList is String
              ? jsonDecode(decodedReturnList) as Map<String, dynamic>
              : decodedReturnList as Map<String, dynamic>,
        ),
      );
    }

    // Handling afterReturnList field
    if (json['after_return_list'] != null) {
      final decodedAfterReturnList = json['after_return_list'] is String
          ? jsonDecode(json['after_return_list'])
          : json['after_return_list'];
      afterReturnList = Rx<Cart?>(
        Cart.fromJson(
          decodedAfterReturnList is String
              ? jsonDecode(decodedAfterReturnList) as Map<String, dynamic>
              : decodedAfterReturnList as Map<String, dynamic>,
        ),
      );
    }

    priceType = RxInt(json['price_type']);
    discount = RxDouble(json['discount']?.toDouble() ?? 0);
    tax = RxDouble(json['tax']?.toDouble() ?? 0);
    returnFee = RxDouble(json['return_fee']?.toDouble() ?? 0);

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
        // payments = RxList<PaymentModel>();
      }
    } else {
      payments = RxList<PaymentModel>();
    }

    debtAmount = RxDouble(json['debt_amount']?.toDouble() ?? 0);
    isDebtPaid = RxBool(json['is_debt_paid'] == 1);

    // Handling otherCosts field
    if (json['other_costs'] != null) {
      final dynamic otherCostsData = json['other_costs'] is String
          ? jsonDecode(json['other_costs'])
          : json['other_costs'];

      if (otherCostsData is List) {
        otherCosts = RxList<OtherCost>(
          otherCostsData
              .map((i) => OtherCost.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        otherCosts = RxList<OtherCost>(
          (jsonDecode(otherCostsData) as List)
              .map((i) => OtherCost.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
        // otherCosts = RxList<OtherCost>();
      }
    } else {
      otherCosts = RxList<OtherCost>();
    }
  }

  InvoiceModel.fromRow(sqlite.Row row)
      : account = Rx<AccountModel>(AccountModel.fromRow(row['account'])),
        id = row['id'],
        storeId = row['store_id'],
        invoiceId = row['invoice_id'],
        createdAt = Rx<DateTime?>(DateTime.parse(row['created_at']).toLocal()),
        customer = Rx<CustomerModel?>(CustomerModel.fromRow(row['customer'])),
        purchaseList = Rx<Cart>(Cart.fromRow(row['purchase_list'])),
        returnList = Rx<Cart?>(row['return_list'] != null
            ? Cart.fromRow(row['return_list'])
            : null),
        afterReturnList = Rx<Cart?>(row['after_return_list'] != null
            ? Cart.fromRow(row['after_return_list'])
            : null),
        priceType = RxInt(row['price_type']),
        discount = RxDouble(row['discount'].toDouble()),
        tax = RxDouble(row['tax'].toDouble()),
        returnFee = RxDouble(row['return_fee'].toDouble() ?? 0),
        payments = RxList<PaymentModel>((row['payments'] as List)
            .map((i) => PaymentModel.fromRow(i))
            .toList()),
        // change = RxDouble(json['change']),
        debtAmount = RxDouble(row['debt_amount'].toDouble()),
        isDebtPaid = RxBool(row['is_debt_paid']),
        otherCosts = RxList<OtherCost>((row['other_costs'] as List)
            .map((i) => OtherCost.fromJson(i))
            .toList());

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['store_id'] = storeId;
    data['invoice_id'] = invoiceId;
    data['account'] = account.value.toJson();
    data['created_at'] = createdAt.value?.toIso8601String();
    data['customer'] = customer.value?.toJson();
    data['purchase_list'] = purchaseList.value.toJson();
    data['return_list'] = returnList.value?.toJson();
    data['after_return_list'] = afterReturnList.value?.toJson();
    data['price_type'] = priceType.value;
    data['discount'] = discount.value;
    data['tax'] = tax.value;
    data['return_fee'] = returnFee.value;
    data['payments'] = payments.map((item) => item.toJson()).toList();
    // data['change'] = change.value;
    data['debt_amount'] = debtAmount.value;
    data['is_debt_paid'] = isDebtPaid.value;
    data['other_costs'] = otherCosts.map((item) => item.toJson()).toList();
    return data;
  }

//! Bill
  double get subtotalBill {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + (item.getSubBill(priceType.value)));
  }

  double get totalBill {
    return purchaseList.value.items
            .fold(0.0, (prev, item) => prev + (item.getBill(priceType.value))) -
        purchaseList.value.bundleDiscount.value +
        totalOtherCosts +
        returnFee.value -
        subtotalAdditionalReturn;
  }

//! Cost
  double get subtotalCost {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + item.subCost);
  }

  double get totalCost {
    return purchaseList.value.items.fold(0, (prev, item) => prev + item.cost);
  }

//! Return
  double get subtotalpurchaseReturn {
    return purchaseList.value.getTotalReturn(priceType.value);
  }

  double get totalPurchaseReturn {
    return subtotalpurchaseReturn - returnFee.value;
  }

  double get subtotalAdditionalReturn {
    double value = 0.0;
    if (returnList.value != null) {
      value = returnList.value!.getTotalReturn(priceType.value);
    }
    return value;
  }

  double get totalAdditionalReturn {
    return subtotalAdditionalReturn - returnFee.value;
  }

  double get totalReturnFinal {
    return subtotalpurchaseReturn + subtotalAdditionalReturn - returnFee.value;
  }

//! Purchase
  double get subTotalPurchase {
    return subtotalBill + subtotalpurchaseReturn;
  }

  double get totalPurchase {
    return totalBill + returnFee.value + totalPurchaseReturn;
  }

  bool get isReturn {
    return subtotalpurchaseReturn + subtotalAdditionalReturn > 0;
  }

  double get remainingReturn {
    return totalReturnFinal - remainingDebt;
  }

  double get totalDiscount {
    return purchaseList.value.bundleDiscount.value +
        purchaseList.value.items
            .fold(0, (prev, item) => prev + (item.individualDiscount.value));
  }

  double get totalTax {
    return subtotalBill * (tax.value ~/ 100);
  }

  double get totalOtherCosts {
    return otherCosts.fold(0, (prev, cost) => prev + cost.amount);
  }

  // double get total {
  //   return subtotalBill - totalDiscount + totalTax + totalOtherCosts;
  // }

  // double get totalFinal {
  //   return totalPurchase - totalReturn;
  // }

  double get totalPaid {
    return payments.fold(0, (prev, payment) => prev + payment.amountPaid);
  }

  double get remainingDebt {
    return totalBill - totalPaid;
  }

  void addPayment(double amount, {String? method, DateTime? date}) {
    payments.add(PaymentModel(
        method: method,
        amountPaid: amount,
        remain: totalBill - (totalPaid + amount),
        finalAmountPaid: (totalPaid + amount) > totalBill
            ? amount + (totalBill - (totalPaid + amount))
            : (totalPaid + amount),
        date: date));
    updateIsDebtPaid();
  }

  void removePayment(PaymentModel paymentModel) {
    payments.remove(paymentModel);
    isDebtPaid.value = remainingDebt <= 0;
  }

  void updateIsDebtPaid() {
    debtAmount.value = totalBill - totalPaid;
    isDebtPaid.value = remainingDebt <= 0;
  }

  void updateReturn() {
    totalReturnFinal;
  }

  void addOtherCost(String name, double amount) {
    otherCosts.add(OtherCost(name: name, amount: amount));
  }

  void removeOtherCost(String name) {
    otherCosts.removeWhere((cost) => cost.name == name);
    isDebtPaid.value = remainingDebt <= 0;
    updateIsDebtPaid();
    updateReturn();
  }

  Map<String, double> totalPaymentsByMethod() {
    Map<String, double> totals = {};
    for (var payment in payments) {
      if (payment.method != null) {
        if (!totals.containsKey(payment.method)) {
          totals[payment.method!] = 0;
        }
        double result = totals[payment.method!]! + payment.amountPaid;
        totals[payment.method!] =
            result <= subtotalBill ? result : subtotalBill;
      }
    }
    return totals;
  }

  double getTotalByMethod(String method) {
    return totalPaymentsByMethod()[method] ?? 0;
  }

  double get totalProfit {
    return subtotalBill -
        subtotalCost -
        totalDiscount -
        totalTax -
        totalOtherCosts;
  }
}
