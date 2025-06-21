import 'dart:convert';

import 'package:powersync/sqlite3_common.dart' as sqlite;
import 'package:get/get.dart';

import '../account_model.dart';
import '../customer_model.dart';
import '../payment_model.dart';
import 'cart_item_model.dart';
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

class RemoveProduct {
  late Rx<DateTime> removeAt;
  late Rx<Cart> removedCart = Rx<Cart>(Cart(items: RxList<CartItem>()));
  // late Rx<Cart> removedCart = Rx<Cart>(Cart(items: RxList<CartItem>()));

  RemoveProduct({
    required DateTime removeAt,
    required Cart removedCart,
  })  : removeAt = Rx<DateTime>(removeAt),
        removedCart = Rx<Cart>(removedCart);

  RemoveProduct.fromJson(Map<String, dynamic> json) {
    removeAt = Rx<DateTime>(
      DateTime.parse(json['remove_at']).toLocal(),
    );

    if (json['remove_product'] is String) {
      final decodedPurchaseList = jsonDecode(json['remove_product']);
      removedCart = Rx<Cart>(
        Cart.fromJson(
          decodedPurchaseList is String
              ? jsonDecode(decodedPurchaseList) as Map<String, dynamic>
              : decodedPurchaseList as Map<String, dynamic>,
        ),
      );
    } else if (json['remove_product'] is Map<String, dynamic>) {
      removedCart = Rx<Cart>(Cart.fromJson(json['remove_product']));
    }
  }

  RemoveProduct.fromRow(sqlite.Row row) {
    removeAt = Rx<DateTime>(
      DateTime.parse(row['remove_at']).toLocal(),
    );

    if (row['remove_product'] is String) {
      final decodedPurchaseList = jsonDecode(row['remove_product']);
      removedCart = Rx<Cart>(
        Cart.fromJson(
          decodedPurchaseList is String
              ? jsonDecode(decodedPurchaseList) as Map<String, dynamic>
              : decodedPurchaseList as Map<String, dynamic>,
        ),
      );
    } else if (row['remove_product'] is Map<String, dynamic>) {
      removedCart = Rx<Cart>(Cart.fromJson(row['remove_product']));
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['remove_at'] = removeAt.value.toIso8601String();
    data['remove_product'] = removedCart.toJson();
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
  late RxList<RemoveProduct> removeProduct = RxList<RemoveProduct>([]);
  late RxDouble debtAmount;
  late RxDouble appBillAmount;
  late RxBool isDebtPaid;
  late RxBool isAppBillPaid;
  late RxList<OtherCost> otherCosts;
  late Rx<DateTime?> initAt;
  late Rx<DateTime?> removeAt;

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
    List<RemoveProduct>? removeProduct,
    double debtAmount = 0,
    double appBillAmount = 0,
    bool isDebtPaid = false,
    bool isAppBillPaid = false,
    List<OtherCost>? otherCosts,
    DateTime? initAt,
    DateTime? removeAt,
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
        removeProduct = RxList<RemoveProduct>(removeProduct ?? []),
        // change = RxDouble(change),
        debtAmount = RxDouble(debtAmount),
        appBillAmount = RxDouble(appBillAmount),
        isDebtPaid = RxBool(isDebtPaid),
        isAppBillPaid = RxBool(isAppBillPaid),
        otherCosts = RxList<OtherCost>(otherCosts ?? []),
        initAt = Rx<DateTime?>(initAt),
        removeAt = Rx<DateTime?>(removeAt);

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

    if (json['remove_product'] != null) {
      // Check if payments is a JSON string
      final dynamic removeData = json['remove_product'] is String
          ? jsonDecode(json['remove_product'])
          : json['remove_product'];

      // Ensure removeData is a list
      if (removeData is List) {
        removeProduct = RxList<RemoveProduct>(
          removeData
              .map((i) => RemoveProduct.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        // Handle the case where removeData is not a list
        removeProduct = RxList<RemoveProduct>(
          (jsonDecode(removeData) as List)
              .map((i) => RemoveProduct.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
        // payments = RxList<PaymentModel>();
      }
    } else {
      removeProduct = RxList<RemoveProduct>();
    }

    debtAmount = RxDouble(json['debt_amount']?.toDouble() ?? 0);
    appBillAmount = RxDouble(json['app_bill_amount']?.toDouble() ?? 0);
    isDebtPaid = RxBool(json['is_debt_paid'] == 1);
    isAppBillPaid = RxBool(json['is_app_bill_paid'] == 1);

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

    initAt = Rx<DateTime?>(
      json['init_at'] != null ? DateTime.parse(json['init_at']) : null,
    );

    removeAt = Rx<DateTime?>(
      json['remove_at'] != null ? DateTime.parse(json['remove_at']) : null,
    );
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
        removeProduct = RxList<RemoveProduct>(row['remove_product'] != null
            ? (row['remove_product'] as List)
                .map((i) => RemoveProduct.fromRow(i))
                .toList()
            : []),
        // change = RxDouble(json['change']),
        debtAmount = RxDouble(row['debt_amount'].toDouble()),
        appBillAmount = RxDouble(row['app_bill_amount'].toDouble()),
        isDebtPaid = RxBool(row['is_debt_paid']),
        isAppBillPaid = RxBool(row['is_app_bill_paid']),
        otherCosts = RxList<OtherCost>((row['other_costs'] as List)
            .map((i) => OtherCost.fromJson(i))
            .toList()),
        initAt = Rx<DateTime?>(DateTime.parse(row['init_at']).toLocal()),
        removeAt = Rx<DateTime?>(DateTime.parse(row['remove_at']).toLocal());

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
    data['remove_product'] = removeProduct.isNotEmpty
        ? removeProduct.map((item) => item.toJson()).toList()
        : [];
    // data['change'] = change.value;
    data['debt_amount'] = debtAmount.value;
    data['app_bill_amount'] = appBillAmount.value;
    data['is_debt_paid'] = isDebtPaid.value;
    data['is_app_bill_paid'] = isAppBillPaid.value;
    data['other_costs'] = otherCosts.map((item) => item.toJson()).toList();
    data['init_at'] = initAt.value?.toIso8601String();
    data['remove_at'] = removeAt.value?.toIso8601String();
    // debugJson(data);
    return data;
  }

  // void debugJson(Map<String, dynamic> data) {
  //   print("debugjson ==================");
  //   data.forEach((key, value) {
  //     print("debugjson $key: $value");
  //   });
  // }

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
        subtotalReturn -
        totalReturnFinal;
  }
  // double get totalBill {
  //   return subtotalBill -
  //       totalDiscount +
  //       totalOtherCosts +
  //       subtotalReturn -
  //       totalReturnFinal;
  // }

//! Cost
  double get subtotalCost {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + item.subCost);
  }

  double get totalCost {
    return purchaseList.value.items.fold(0, (prev, item) => prev + item.cost);
  }

//! Return
  double get subtotalReturn {
    return purchaseList.value.getTotalReturn(priceType.value);
  }

  // double get totalPurchaseReturn {
  //   return subtotalpurchaseReturn - returnFee.value;
  // }

  double get subtotalAdditionalReturn {
    double value = 0.0;
    if (returnList.value != null) {
      value = returnList.value!.getTotalReturn(priceType.value);
    }
    return value;
  }

  // double get totalAdditionalReturn {
  //   return subtotalAdditionalReturn - returnFee.value;
  // }

  double get totalReturn {
    return subtotalReturn + subtotalAdditionalReturn;
  }

  double get totalReturnFinal {
    return totalReturn - returnFee.value;
  }

//! Purchase
  double get subTotalPurchase {
    return subtotalBill + subtotalReturn;
  }

  double get totalPurchase {
    return totalBill + totalReturnFinal;
  }

  bool get isReturn {
    return subtotalReturn + subtotalAdditionalReturn > 0;
  }

  double get remainingReturn {
    return totalReturnFinal - remainingDebt;
  }

  double get additionalDIscount {
    return purchaseList.value.bundleDiscount.value;
  }

  double get totalInvididualDiscount {
    return purchaseList.value.items
        .fold(0, (prev, item) => prev + (item.individualDiscount.value));
  }

  double get totalDiscount {
    return additionalDIscount +
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

  double totalPaidByIndex(int index) {
    var sublist = payments.sublist(0, index + 1);

    double total = sublist
        .map((payment) => payment.finalAmountPaid)
        .reduce((a, b) => a + b);
    return total;
  }

  double get subtotalPaid {
    return payments.asMap().entries.fold(0, (prev, entry) {
      int index = entry.key;
      PaymentModel payment = entry.value;

      if (index == payments.length - 1) {
        return prev +
            (prev + payment.amountPaid > totalBill
                ? payment.amountPaid
                : payment.finalAmountPaid);
      } else {
        return prev + payment.finalAmountPaid;
      }
    });
  }

  double get totalPaid {
    return payments.fold(0, (prev, payment) => prev + payment.finalAmountPaid);
  }

  double get remainingDebt {
    //  print('payment data ${subtotalPaid}');
    return totalBill - subtotalPaid;
  }

  double get remainingCost {
    //  print('payment data ${subtotalPaid}');
    return totalCost - subtotalPaid;
  }

  void addPayment(double amount, {String? method, DateTime? date}) {
    double finalAmountPaid = amount;
    double remaining = totalBill - totalPaid;

    if (finalAmountPaid > remaining) {
      finalAmountPaid = remaining;
    }

    payments.add(PaymentModel(
      storeId: storeId,
      method: method,
      amountPaid: amount,
      remain: totalBill - (totalPaid + amount),
      finalAmountPaid: finalAmountPaid,
      date: date,
    ));
    updateIsDebtPaid();
  }

  void removePayment(PaymentModel paymentModel) {
    payments.remove(paymentModel);
    updateIsDebtPaid();
  }

  void updateIsDebtPaid() {
    debtAmount.value = remainingDebt;
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

  // Map<String, double> totalPaymentsByMethod() {
  //   Map<String, double> totals = {};
  //   for (var payment in payments) {
  //     if (payment.method != null) {
  //       if (!totals.containsKey(payment.method)) {
  //         totals[payment.method!] = 0;
  //       }
  //       double result = totals[payment.method!]! + payment.amountPaid;
  //       totals[payment.method!] =
  //           result <= subtotalBill ? result : subtotalBill;
  //     }
  //   }
  //   return totals;
  // }

  Map<String, Map<String, double>> totalPaymentsByMethodAndDebtStatus(
      {DateTime? selectedDate}) {
    Map<String, Map<String, double>> totals = {};
    for (var payment in payments) {
      if (payment.method != null) {
        bool isDebt = payment.date!.isAfter(DateTime(createdAt.value!.year,
            createdAt.value!.month, createdAt.value!.day + 1, 0, 0, 0));

        String debtStatus = isDebt ? "debt" : "pay";
        if (!totals.containsKey(payment.method)) {
          totals[payment.method!] = {"debt": 0, "pay": 0, "deposit": 0};
        }
        double prev = totals[payment.method!]![debtStatus]!;
        double result = prev + payment.amountPaid;

        double adjustment = result;
        adjustment += payment.method == 'cash'
            ? (totals['transfer']?[debtStatus] ?? 0) + (totals['deposit']?[debtStatus] ?? 0)
            : (totals['cash']?[debtStatus] ?? 0) + (totals['deposit']?[debtStatus] ?? 0);


        if (adjustment > totalBill) {
          result -= adjustment - totalBill;
        }
        totals[payment.method!]![debtStatus] = result;
      }
    }
    return totals;
  }

  double getTotalPayByMethod(String method, {DateTime? selectedDate}) {
    Map<String, Map<String, double>> totals =
        totalPaymentsByMethodAndDebtStatus(selectedDate: selectedDate);
    return totals[method]?["pay"] ?? 0;
  }

  double getTotalDebtByMethod(String method, {DateTime? selectedDate}) {
    Map<String, Map<String, double>> totals =
        totalPaymentsByMethodAndDebtStatus(selectedDate: selectedDate);
    return totals[method]?["debt"] ?? 0;
  }

  double get totalProfit {
    return subtotalBill -
        subtotalCost -
        totalDiscount -
        totalTax -
        totalOtherCosts;
  }

  double get totalRemovedValue {
    List<RemoveProduct> removedProduct = removeProduct
        .where((re) => re.removeAt.value.isAfter(DateTime(
            initAt.value!.year, initAt.value!.month, initAt.value!.day + 1)))
        .toList();
    var aa = removedProduct.fold(
        0.0,
        (prev, item) =>
            prev + (item.removedCart.value.getTotalBill(priceType.value)));
    // print('removedProduct ${removedProduct.length}');
    // print('removedProduct ${removedProduct[0].toJson()}');
    print('removedProduct $aa');
    return aa;
  }

  double get totalAppBill {
    return totalPurchase * 0.01;
  }
}
