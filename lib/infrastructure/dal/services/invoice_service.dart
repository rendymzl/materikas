import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
// import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:powersync/sqlite3_common.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../domain/core/interfaces/invoice_repository.dart';
import '../../../main.dart';
import '../../models/chart_model.dart';
import '../../models/invoice_model/cart_item_model.dart';
import '../../models/invoice_model/invoice_model.dart';
// import '../../models/payment_model.dart';
import '../../models/payment_model.dart';
import '../../utils/display_format.dart';
import '../database/powersync.dart';
import 'invoice_isolate_stream.dart';

// Future<List<InvoiceModel>> convertToInvoiceListPaid(
//     List<Map<String, dynamic>> maps) async {
//   return maps
//       .where((e) => e['is_debt_paid'] == 1)
//       .map((e) => InvoiceModel.fromJson(e))
//       .toList();
// }

// Future<List<InvoiceModel>> convertToInvoiceListDebt(
//     List<Map<String, dynamic>> maps) async {
//   return maps
//       .where((e) => e['is_debt_paid'] == 0)
//       .map((e) => InvoiceModel.fromJson(e))
//       .toList();
// }

List<Chart> convertToChartModel(List<Map<String, dynamic>> result) {
  return result.map((e) => Chart.fromJson(e)).toList();
}

List<InvoiceModel> convertToInvoiceModel(List<Map<String, dynamic>> result) {
  return result.map((e) => InvoiceModel.fromJson(e)).toList();
}

List<PaymentModel> convertToPaymentModel(List<Map<String, dynamic>> result) {
  return result.map((e) => PaymentModel.fromJson(e)).toList();
}

// Future<List<PaymentMapModel>> convertToPaymentModel(
//     List<Map<String, dynamic>> maps) async {
//   return maps.map((e) => PaymentMapModel.fromJson(e)).toList();
// }

class InvoiceService extends GetxService implements InvoiceRepository {
  //!===================== INFINITY SCROLL: VARIABLE =====================
  // final updatedPaidCount = 0.obs;
  // final updatedDebtCount = 0.obs;

// , parameters: [
//       DateFormat('yyyy-MM-dd').format(DateTime.now()),
//       DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1))),
//     ]

  var itemsPaid = <InvoiceModel>[].obs;
  var itemsDebt = <InvoiceModel>[].obs;

  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    once(itemsDebt, (_) => isReady.value = true);
  }
  //!===================== INFINITY SCROLL: FUNCTION =====================

  // late Stream<List<InvoiceModel>> itemsPaidStream;
  // Isolate? isolate;

  // Future<void> startPaidIsolate() async {
  //   // Membuat ReceivePort untuk menerima stream dari Isolate
  //   final receivePort = ReceivePort();

  //   print('listenPaid: Prepare isolatePaidStream');
  //   // Memulai Isolate
  //   isolate = await Isolate.spawn(isolatePaidStream, receivePort.sendPort);
  //   // isolate?.controlPort;
  //   receivePort.listen((datas) {
  //     print('listenPaid: $datas');
  //     itemsPaid(datas);
  //   });
  // }

  @override
  Future<void> subscribe() async {
    var startTime = DateTime.now();

    final invoicePaidStream = db.watch('''
    SELECT
      invoices.id,
      invoices.store_id,
      invoices.invoice_id,
      invoices.created_at,
      invoices.account,
      invoices.customer,
      invoices.purchase_list,
      invoices.return_list,
      invoices.after_return_list,
      invoices.price_type,
      invoices.discount,
      invoices.tax,
      invoices.return_fee,
      invoices.remove_product,
      invoices.debt_amount,
      invoices.app_bill_amount,
      invoices.is_debt_paid,
      invoices.is_app_bill_paid,
      invoices.other_costs,
      invoices.init_at,
      invoices.remove_at,
        '[' || GROUP_CONCAT(
        '{ "id": "' || payments.id || '"' ||
        ', "invoice_id": "' || payments.invoice_id || '"' ||
        ', "store_id": "' || payments.store_id || '"' ||
        ', "invoice_created_at": "' || payments.invoice_created_at || '"' ||
        ', "date": "' || payments.date || '"' ||
        ', "method": "' || payments.method || '"' ||
        ', "final_amount_paid": ' || payments.final_amount_paid ||
        ', "remain": ' || payments.remain ||
        ', "amount_paid": ' || payments.amount_paid || 
        '}', ', '
      ) || ']' AS payments
    FROM
      invoices
    LEFT JOIN
      payments ON invoices.invoice_id = payments.invoice_id
    WHERE
      invoices.created_at BETWEEN ? AND ?
      AND invoices.remove_at IS NULL
      AND invoices.is_debt_paid = 1
    GROUP BY
      invoices.invoice_id
    ORDER BY
      invoices.created_at DESC;
      ''', parameters: [
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1))),
    ]).map((data) => data.toList());

    invoicePaidStream.listen((datas) async {
      // print('datasdatasdatas ${datas[0]['payments']}');
      var dataModel = await compute(convertToInvoiceModel, datas);
      itemsPaid.value = dataModel;
      // updatedPaidCount.value++;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(
          'Waktu pengambilan data listenPaid ${datas.length}: ${duration.inMilliseconds} ms');
    });

    startTime = DateTime.now();
    final invoiceDebtStream = db.watch(
      '''
      SELECT
        invoices.id,
        invoices.store_id,
        invoices.invoice_id,
        invoices.created_at,
        invoices.account,
        invoices.customer,
        invoices.purchase_list,
        invoices.return_list,
        invoices.after_return_list,
        invoices.price_type,
        invoices.discount,
        invoices.tax,
        invoices.return_fee,
        invoices.remove_product,
        invoices.debt_amount,
        invoices.app_bill_amount,
        invoices.is_debt_paid,
        invoices.is_app_bill_paid,
        invoices.other_costs,
        invoices.init_at,
        invoices.remove_at,
          '[' || GROUP_CONCAT(
          '{ "id": "' || payments.id || '"' ||
          ', "invoice_id": "' || payments.invoice_id || '"' ||
          ', "store_id": "' || payments.store_id || '"' ||
          ', "invoice_created_at": "' || payments.invoice_created_at || '"' ||
          ', "date": "' || payments.date || '"' ||
          ', "method": "' || payments.method || '"' ||
          ', "final_amount_paid": ' || payments.final_amount_paid ||
          ', "remain": ' || payments.remain ||
          ', "amount_paid": ' || payments.amount_paid || 
          '}', ', '
        ) || ']' AS payments
      FROM
        invoices
      LEFT JOIN
        payments ON invoices.invoice_id = payments.invoice_id
      WHERE invoices.remove_at IS NULL
        AND invoices.is_debt_paid = 0
      GROUP BY
        invoices.invoice_id
      ORDER BY
        invoices.created_at DESC;
      ''',
    ).map((data) => data.toList());
    // final invoiceDebtStream = db.watch('''
    //   SELECT invoices.*,
    //   payments.id AS payment_id,
    //   payments.invoice_id AS payment_invoice_id,
    //   payments.created_at AS payment_created_at,
    //   payments.remove_at AS payment_remove_at,
    //   payments.amount_paid,
    //   payments.remain,
    //   payments.final_amount_paid,
    //   payments.store_id AS payment_store_id,
    //   payments.invoice_created_at AS payment_invoice_created_at,
    //   payments.method
    //   FROM invoices
    //   LEFT JOIN payments ON invoices.id = payments.invoice_id
    //   ''', parameters: [
    //   DateFormat('yyyy-MM-dd').format(DateTime.now()),
    //   DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1))),
    // ]).map((data) => data.toList());

    invoiceDebtStream.listen((datas) async {
      var dataModel = await compute(convertToInvoiceModel, datas);
      itemsDebt.value = dataModel;
      // updatedDebtCount.value++;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(
          'Waktu pengambilan data listenDebt ${datas.length}: ${duration.inMilliseconds} ms');
    });
  }

  Future<List<InvoiceModel>> fetch({
    bool? isPaid,
    int offset = 15,
    int limit = 15,
    String search = '',
    PickerDateRange? pickerDateRange,
    String methodPayment = '',
  }) async {
    print('methodPayment ${methodPayment.isNotEmpty} $pickerDateRange');
    final query = '''
      SELECT * FROM invoices WHERE remove_at IS NULL
      AND is_debt_paid = ?
      ${search.isNotEmpty ? 'AND (customer LIKE ? OR invoice_id LIKE ?)' : ''}
      ${pickerDateRange != null ? 'AND created_at BETWEEN ? AND ?' : ''}
      ${methodPayment.isNotEmpty ? 'AND payments LIKE ?' : ''}
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    ''';

    final parameters = [
      isPaid! ? 1 : 0,
      if (search.isNotEmpty) '%$search%',
      if (search.isNotEmpty) '%$search%',
      if (pickerDateRange != null)
        DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
      if (pickerDateRange != null)
        DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
      if (methodPayment.isNotEmpty) '%$methodPayment%',
      limit,
      offset,
    ];

    final result = await db.getAll(query, parameters);
    final listInvoices = result.map((e) => InvoiceModel.fromJson(e)).toList();
    return listInvoices;
  }

  //!===================== SEARCH: VARIABLE =====================
  // var filteredPaidInv = <InvoiceModel>[].obs;
  // var filteredDebtInv = <InvoiceModel>[].obs;

  //!===================== SEARCH: FUNCTION =====================
  // Future<void> applyFilters() async {
  //   var paidInvResult = <InvoiceModel>[].obs;
  //   var debtInvResult = <InvoiceModel>[].obs;

  //   if (searchDateQuery.value != null) {
  //     paidInvResult.value =
  //         await getByCreatedDate(searchDateQuery.value!, paid: true);
  //     debtInvResult.value =
  //         await getByCreatedDate(searchDateQuery.value!, paid: false);
  //   }

  //   if (methodPayment.value.isNotEmpty && searchDateQuery.value == null) {
  //     paidInvResult.value =
  //         await searchByPaymentMethod(methodPayment.value, true);
  //     debtInvResult.value =
  //         await searchByPaymentMethod(methodPayment.value, false);
  //   }

  //   if (searchQuery.value.isNotEmpty) {
  //     if (searchDateQuery.value != null || methodPayment.value.isNotEmpty) {
  //       if (searchDateQuery.value != null) {
  //         var paid = paidInvResult
  //             .where((invoice) =>
  //                 invoice.customer.value!.name
  //                     .toLowerCase()
  //                     .contains(searchQuery.value.toLowerCase()) ||
  //                 invoice.invoiceId!
  //                     .toLowerCase()
  //                     .contains(searchQuery.value.toLowerCase()))
  //             .toList();
  //         var debt = debtInvResult
  //             .where((invoice) =>
  //                 invoice.customer.value!.name
  //                     .toLowerCase()
  //                     .contains(searchQuery.value.toLowerCase()) ||
  //                 invoice.invoiceId!
  //                     .toLowerCase()
  //                     .contains(searchQuery.value.toLowerCase()))
  //             .toList();
  //         paidInvResult.value = paid;
  //         debtInvResult.value = debt;
  //       }
  //       if (methodPayment.value.isNotEmpty) {
  //         var paid = paidInvResult
  //             .where((invoice) =>
  //                 (invoice.customer.value!.name
  //                         .toLowerCase()
  //                         .contains(searchQuery.value.toLowerCase()) ||
  //                     invoice.invoiceId!
  //                         .toLowerCase()
  //                         .contains(searchQuery.value.toLowerCase())) &&
  //                 invoice.payments.any((payment) => payment.method!
  //                     .toLowerCase()
  //                     .contains(methodPayment.value.toLowerCase())))
  //             .toList();
  //         var debt = debtInvResult
  //             .where((invoice) =>
  //                 (invoice.customer.value!.name
  //                         .toLowerCase()
  //                         .contains(searchQuery.value.toLowerCase()) ||
  //                     invoice.invoiceId!
  //                         .toLowerCase()
  //                         .contains(searchQuery.value.toLowerCase())) &&
  //                 invoice.payments.any((payment) => payment.method!
  //                     .toLowerCase()
  //                     .contains(methodPayment.value.toLowerCase())))
  //             .toList();
  //         paidInvResult.value = paid;
  //         debtInvResult.value = debt;
  //       }
  //     } else {
  //       paidInvResult.value = await searchInv(searchQuery.value, true);
  //       debtInvResult.value = await searchInv(searchQuery.value, false);
  //     }
  //   }

  //   filteredPaidInv.value = paidInvResult
  //     ..sort((a, b) => DateTime.parse(b.createdAt.value!.toIso8601String())
  //         .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
  //   filteredDebtInv.value = debtInvResult
  //     ..sort((a, b) => DateTime.parse(b.createdAt.value!.toIso8601String())
  //         .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
  // }

  Future<List<InvoiceModel>> searchInv(String searchTerm, bool paid) async {
    String query = '''
        SELECT * FROM invoices WHERE
        (customer LIKE ? OR
        invoice_id LIKE ?) AND
        is_debt_paid = ?
        AND remove_at IS NULL
        ''';
    List<Map<String, dynamic>> results = await db.getAll(query, [
      '%${searchTerm.toLowerCase()}%',
      '%${searchTerm.toLowerCase()}%',
      paid,
    ]);
    return results.map((e) => InvoiceModel.fromJson(e)).toList();
  }

  Future<List<InvoiceModel>> searchByPaymentMethod(
      String searchTerm, bool paid) async {
    if (paid) {
      String query = '''
        SELECT * FROM invoices WHERE
        payments LIKE ? AND
        is_debt_paid = ?
        AND remove_at IS NULL
        LIMIT 200
        ''';
      List<Map<String, dynamic>> results = await db.getAll(query, [
        '%${searchTerm.toLowerCase()}%',
        paid,
      ]);
      return results.map((e) => InvoiceModel.fromJson(e)).toList();
    } else {
      String query = '''
        SELECT * FROM invoices WHERE
        payments LIKE ? AND
        is_debt_paid = ?
        AND remove_at IS NULL
        ''';
      List<Map<String, dynamic>> results = await db.getAll(query, [
        '%${searchTerm.toLowerCase()}%',
        paid,
      ]);
      return results.map((e) => InvoiceModel.fromJson(e)).toList();
    }
  }

  @override
  Future<List<InvoiceModel>> getByCreatedDate(PickerDateRange pickerDateRange,
      {bool? paid}) async {
    String query = '''
      SELECT * FROM invoices WHERE
      created_at BETWEEN ? AND ?
      AND remove_at IS NULL
      ${paid != null ? 'AND is_debt_paid = ?' : ''}
      ORDER BY created_at DESC
      ''';

    List<dynamic> params = [
      DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
      DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
    ];

    if (paid != null) {
      params.add(paid ? 1 : 0);
    }

    List<Map<String, dynamic>> results = await db.getAll(query, params);

    // Gunakan compute untuk konversi data di background thread
    var invoiceList = await compute(convertToInvoiceModel, results);
    return invoiceList;
  }

  Future<List<InvoiceModel>> getBillInvoice(DateTime date) async {
    PickerDateRange pickerDateRange = PickerDateRange(
        DateTime(date.year, date.month, 1),
        DateTime(date.year, date.month + 1, 1));

    String query = '''
      SELECT * FROM invoices WHERE
      init_at BETWEEN ? AND ?
      ''';
    List<Map<String, dynamic>> results = await db.getAll(query, [
      DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
      DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
    ]);
    return results.map((e) => InvoiceModel.fromJson(e)).toList()
      ..sort((a, b) => a.initAt.value!.compareTo(b.initAt.value!));
  }

  String generateInvoiceNumber(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return 'BILL-$year$month';
  }

  @override
  Future<List<InvoiceModel>> getByPaymentDate(DateTime datetime) async {
    String query = '''
      SELECT * FROM invoices WHERE
      payments LIKE ?
      ''';
    List<Map<String, dynamic>> results = await db.getAll(query, [
      '%${DateFormat('yyyy-MM-dd').format(datetime)}%',
    ]);
    var invoiceList = results.map((e) => InvoiceModel.fromJson(e)).toList();
    print('getByPaymentDate $invoiceList');
    return invoiceList;
  }

  Future<List<InvoiceModel>> getInvByDate(
      DateTime startDate, DateTime endDate) async {
    String query = '''
      SELECT * FROM invoices WHERE
      created_at BETWEEN ? AND ?
      ''';
    List<Map<String, dynamic>> results = await db.getAll(query, [
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate.add(Duration(days: 1)).subtract(Duration(seconds: 1))),
    ]);
    var invoiceList = results.map((e) => InvoiceModel.fromJson(e)).toList();
    print('logStock detail $invoiceList');
    return invoiceList;
  }

  // Future<List<PaymentMapModel>> getPaymentByDate(
  //     PickerDateRange pickerDateRange) async {
  //   String query = '''
  //   SELECT id, created_at, payments
  //   FROM invoices
  //   WHERE remove_at IS NULL
  //   AND payments NOT NULL
  //   ''';

  //   List<Map<String, dynamic>> results = await db.getAll(query);
  //   List<PaymentMapModel> paymentsMap =
  //       await compute(convertToPaymentModel, results);
  //   List<PaymentMapModel> filteredPayments = [];

  //   DateTime startDate = pickerDateRange.startDate!;
  //   DateTime endDate = pickerDateRange.endDate!;

  //   filteredPayments = paymentsMap.where((paymentMap) {
  //     return paymentMap.payments
  //         .where((payment) =>
  //             payment.date!.isAfter(startDate) &&
  //             payment.date!.isBefore(endDate))
  //         .isNotEmpty;
  //   }).toList();

  //   return filteredPayments;
  // }

  // Future<List<PaymentModel>> getPaymentByDate(
  //     PickerDateRange pickerDateRange) async {
  //   var results = await db.getAll('''
  //   SELECT * FROM payments
  //   WHERE date BETWEEN ? AND ?
  //   AND invoices.remove_at IS NULL
  //   ORDER BY invoices.created_at DESC;
  //     ''', [
  //     DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
  //     DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
  //   ]);
  //   return await compute(convertToPaymentModel, results);
  // }
  Future<List<InvoiceModel>> getPaymentByDate(
      PickerDateRange pickerDateRange) async {
    List<Map<String, dynamic>> results = await db.getAll('''
SELECT
  invoices.id,
  invoices.store_id,
  invoices.invoice_id,
  invoices.created_at,
  invoices.account,
  invoices.customer,
  invoices.purchase_list,
  invoices.return_list,
  invoices.after_return_list,
  invoices.price_type,
  invoices.discount,
  invoices.tax,
  invoices.return_fee,
  invoices.remove_product,
  invoices.debt_amount,
  invoices.app_bill_amount,
  invoices.is_debt_paid,
  invoices.is_app_bill_paid,
  invoices.other_costs,
  invoices.init_at,
  invoices.remove_at,
    '[' || GROUP_CONCAT(
    '{ "id": "' || payments.id || '"' ||
    ', "invoice_id": "' || payments.invoice_id || '"' ||
    ', "store_id": "' || payments.store_id || '"' ||
    ', "invoice_created_at": "' || payments.invoice_created_at || '"' ||
    ', "date": "' || payments.date || '"' ||
    ', "method": "' || payments.method || '"' ||
    ', "final_amount_paid": ' || payments.final_amount_paid ||
    ', "remain": ' || payments.remain ||
    ', "amount_paid": ' || payments.amount_paid ||
    '}', ', '
  ) || ']' AS payments
FROM
  invoices
LEFT JOIN
  payments ON invoices.invoice_id = payments.invoice_id
WHERE
  payments.date BETWEEN ? AND ?
  AND invoices.remove_at IS NULL
GROUP BY
  invoices.invoice_id
ORDER BY
  invoices.created_at DESC;
      ''', [
      DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
      DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
    ]);
    return await compute(convertToInvoiceModel, results);
  }

  //!===================== CREATE UPDATE DELETE =====================
  @override
  Future<void> insert(InvoiceModel invoice) async {
    await db.execute(
      '''
    INSERT INTO invoices(
      id, store_id, invoice_id, account, created_at, customer, purchase_list,
      return_list, after_return_list, price_type, discount, tax, return_fee, payments,
      remove_product, debt_amount, app_bill_amount, is_debt_paid, is_app_bill_paid, other_costs, init_at, remove_at
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        // invoice.id,
        invoice.storeId,
        invoice.invoiceId,
        invoice.account.value.toJson(),
        invoice.createdAt.value?.toIso8601String(),
        invoice.customer.value,
        invoice.purchaseList.value.toJson(),
        invoice.returnList.value?.toJson(),
        invoice.afterReturnList.value?.toJson(),
        invoice.priceType.value,
        invoice.discount.value,
        invoice.tax.value,
        invoice.returnFee.value,
        invoice.payments.map((e) => e.toJson()).toList(),
        invoice.removeProduct.map((e) => e.toJson()).toList(),
        invoice.debtAmount.value,
        invoice.appBillAmount.value,
        invoice.isDebtPaid.value ? 1 : 0,
        invoice.isAppBillPaid.value ? 1 : 0,
        invoice.otherCosts.map((e) => e.toJson()).toList(),
        invoice.initAt.value?.toIso8601String(),
        invoice.removeAt.value?.toIso8601String(),
      ],
    );

    await insertListPayments(
        invoice.payments, invoice.createdAt.value?.toIso8601String());
  }

  Future<void> insertListPayments(
      List<PaymentModel> paymentList, String? invoiceCreatedAt) async {
    final List<List<Object?>> parameterSets = paymentList.map((payment) {
      print('paymentInsert ${payment.toJson()}');
      return [
        payment.invoiceId,
        payment.storeId,
        invoiceCreatedAt,
        payment.date!.toIso8601String(),
        payment.removeAt?.toIso8601String(),
        payment.amountPaid,
        payment.method,
        payment.finalAmountPaid,
        payment.remain
      ];
    }).toList();

    await db.executeBatch(
      '''
    INSERT INTO payments(
      id, invoice_id, store_id, invoice_created_at, date, remove_at, amount_paid, method, final_amount_paid, 
      remain
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      parameterSets,
    );
  }

  Future<void> insertListReturnItems(
      List<CartItem> itemCartList, InvoiceModel inv) async {
    print('return debug: insert dimulai');

    final List<List<Object?>> parameterSets = itemCartList
        .where((items) => items.quantityReturn.value > 0)
        .map((items) {
      print('return debug: ${items.toJson()}');
      return [
        inv.invoiceId,
        items.product.storeId,
        items.returnDate.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        jsonEncode(items.product.toJson()),
        items.quantityReturn.value,
        inv.returnFee.value,
        items.individualDiscount.value,
        inv.priceType.value
      ];
    }).toList();

    print('return debug: parameterSets $parameterSets');
    await db.executeBatch(
      '''
    INSERT INTO return_items(
      id, invoice_id, store_id, created_at, product, quantity_return, return_fee, individual_discount, price_type
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      parameterSets,
    );
  }

  @override
  Future<void> update(InvoiceModel updatedInvoice) async {
    try {
      await db.execute(
        '''
    UPDATE invoices SET
      store_id = ?, 
      invoice_id = ?, 
      account = ?, 
      created_at = ?, 
      customer = ?, 
      purchase_list = ?, 
      return_list = ?, 
      after_return_list = ?, 
      price_type = ?, 
      discount = ?, 
      tax = ?, 
      return_fee = ?, 
      payments = ?, 
      remove_product = ?, 
      debt_amount = ?, 
      app_bill_amount = ?, 
      is_debt_paid = ?, 
      is_app_bill_paid = ?, 
      other_costs = ?,
      remove_at = ?
    WHERE id = ?
    ''',
        [
          updatedInvoice.storeId,
          updatedInvoice.invoiceId,
          updatedInvoice.account.value.toJson(),
          updatedInvoice.createdAt.value?.toIso8601String(),
          updatedInvoice.customer.value?.toJson(),
          updatedInvoice.purchaseList.value.toJson(),
          updatedInvoice.returnList.value?.toJson(),
          updatedInvoice.afterReturnList.value?.toJson(),
          updatedInvoice.priceType.value,
          updatedInvoice.discount.value,
          updatedInvoice.tax.value,
          updatedInvoice.returnFee.value,
          updatedInvoice.payments.map((e) => e.toJson()).toList(),
          updatedInvoice.removeProduct.map((e) => e.toJson()).toList(),
          updatedInvoice.debtAmount.value,
          updatedInvoice.appBillAmount.value,
          updatedInvoice.isDebtPaid.value ? 1 : 0,
          updatedInvoice.isAppBillPaid.value ? 1 : 0,
          updatedInvoice.otherCosts.map((e) => e.toJson()).toList(),
          updatedInvoice.removeAt.value?.toIso8601String(),
          updatedInvoice.id,
        ],
      );

      print('return debug: dimulai');

      await db.execute('DELETE FROM payments WHERE invoice_id = ?',
          [updatedInvoice.invoiceId]);

      await insertListPayments(updatedInvoice.payments,
          updatedInvoice.createdAt.value?.toIso8601String());
      print('return debug: clear dimulai');

      await db.execute('DELETE FROM return_items WHERE invoice_id = ?',
          [updatedInvoice.invoiceId]);

      // for (var payment in updatedInvoice.payments) {
      //   print('update invoice payments ${payment.toJson()}');
      // }
      print('return debug: berhasil di clear');
      await insertListReturnItems(
          updatedInvoice.purchaseList.value.items, updatedInvoice);
      if (updatedInvoice.returnList.value != null &&
          updatedInvoice.returnList.value!.items.isNotEmpty) {
        await insertListReturnItems(
            updatedInvoice.returnList.value!.items, updatedInvoice);
      }

      print('return debug: selesai');
      print('berhasil update invoice ${updatedInvoice.invoiceId}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateList(List<InvoiceModel> updatedInvoiceList) async {
    final List<List<Object?>> parameterSets =
        updatedInvoiceList.map((updatedInvoice) {
      return [
        updatedInvoice.storeId,
        updatedInvoice.invoiceId,
        jsonEncode(updatedInvoice.account.value.toJson()),
        updatedInvoice.createdAt.value?.toIso8601String(),
        jsonEncode(updatedInvoice.customer.value?.toJson()),
        jsonEncode(updatedInvoice.purchaseList.value.toJson()),
        jsonEncode(updatedInvoice.returnList.value?.toJson()),
        updatedInvoice.afterReturnList.value != null
            ? jsonEncode(updatedInvoice.afterReturnList.value?.toJson())
            : null,
        updatedInvoice.priceType.value,
        updatedInvoice.discount.value,
        updatedInvoice.tax.value,
        updatedInvoice.returnFee.value,
        // jsonEncode(updatedInvoice.payments
        //     .map((e) => e.toJson())
        //     .toList()), // Convert list of Maps to JSON string
        jsonEncode(updatedInvoice.removeProduct
            .map((e) => e.toJson())
            .toList()), // Convert list of Maps to JSON string
        updatedInvoice.debtAmount.value,
        updatedInvoice.appBillAmount.value,
        updatedInvoice.isDebtPaid.value ? 1 : 0,
        updatedInvoice.isAppBillPaid.value ? 1 : 0,
        jsonEncode(updatedInvoice.otherCosts
            .map((e) => e.toJson())
            .toList()), // Convert list of Maps to JSON string
        updatedInvoice.removeAt.value?.toIso8601String(),
        updatedInvoice.id,
      ];
    }).toList();

    await db.executeBatch(
      '''
    UPDATE invoices SET
      store_id = ?, 
      invoice_id = ?, 
      account = ?, 
      created_at = ?, 
      customer = ?, 
      purchase_list = ?, 
      return_list = ?, 
      after_return_list = ?, 
      price_type = ?, 
      discount = ?, 
      tax = ?, 
      return_fee = ?, 
      remove_product = ?, 
      debt_amount = ?, 
      app_bill_amount = ?, 
      is_debt_paid = ?, 
      is_app_bill_paid = ?, 
      other_costs = ?,
      remove_at = ?
    WHERE id = ?
    ''',
      parameterSets,
    );

    for (var invoice in updatedInvoiceList) {
      await db.execute(
          'DELETE FROM payments WHERE invoice_id = ?', [invoice.invoiceId]);

      await insertListPayments(
          invoice.payments, invoice.createdAt.value?.toIso8601String());
    }
  }

  @override
  Future<void> delete(String id) async {
    // await db.execute('DELETE FROM invoices WHERE id = ?', [id]);
    try {
      await db.execute(
        '''
    UPDATE invoices SET
      remove_at = ?
    WHERE id = ?
    ''',
        [DateTime.now(), id],
      );

      await db.execute(
        '''
    UPDATE payments SET
      remove_at = ?
    WHERE invoice_id = ?
    ''',
        [DateTime.now(), id],
      );
    } catch (e) {
      e.toString();
    }
  }

  Future<List<Chart>> getChartList(PickerDateRange pickerDateRange,
      {bool? paid}) async {
    //   '[' || GROUP_CONCAT(
    //   '{ "id": "' || p.id || '"' ||
    //   ', "invoice_id": "' || p.invoice_id || '"' ||
    //   ', "invoice_created_at": "' || p.invoice_created_at || '"' ||
    //   ', "date": "' || p.date || '"' ||
    //   ', "method": "' || p.method || '"' ||
    //   ', "final_amount_paid": ' || p.final_amount_paid ||
    //   '}', ', '
    // ) || ']' AS payments,
    //   '[' || GROUP_CONCAT(
    //   '{ "id": "' || p2.id || '"' ||
    //   ', "invoice_id": "' || p2.invoice_id || '"' ||
    //   ', "invoice_created_at": "' || p2.invoice_created_at || '"' ||
    //   ', "date": "' || p2.date || '"' ||
    //   ', "method": "' || p2.method || '"' ||
    //   ', "final_amount_paid": ' || p2.final_amount_paid ||
    //   '}', ', '
    // ) || ']' AS debt_payments
    String purchaseQuery = '''
    WITH 
      all_dates AS (
        SELECT DATE(created_at) AS date FROM invoices WHERE remove_at IS NULL
        UNION
        SELECT DATE(date) FROM payments
        UNION
        SELECT DATE(created_at) FROM operating_costs
        UNION
        SELECT DATE(created_at) FROM return_items
        UNION
        SELECT DATE(date) FROM payments_sales
      ),

      payments_aggregated AS (
        SELECT 
          DATE(date) AS date,
          method,
          SUM(final_amount_paid) AS total
        FROM payments
        WHERE DATE(date) = DATE(invoice_created_at)
        GROUP BY DATE(date), method
      ),

      payments_debt_aggregated AS (
        SELECT 
          DATE(date) AS date,
          method,
          SUM(final_amount_paid) AS total
        FROM payments
        WHERE DATE(date) > DATE(invoice_created_at)
        GROUP BY DATE(date), method
      ),

      payments_sales_aggregated AS (
        SELECT 
          DATE(date) AS date,
          method,
          SUM(final_amount_paid) AS total
        FROM payments_sales
        GROUP BY DATE(date), method
      ),

      operating_costs_aggregated AS (
        SELECT 
          DATE(created_at) AS date,
          SUM(amount) AS total
        FROM operating_costs
        GROUP BY DATE(created_at)
      ),

      return_items_json_grouped AS (
        SELECT 
          DATE(date) AS date,
          '[' || GROUP_CONCAT(json_str, ', ') || ']' AS return_items
        FROM (
          SELECT 
            DATE(created_at) AS date,
            '{ "product": ' || IFNULL(product, '') ||
            ', "return_fee": "' || IFNULL(return_fee, '') || '"' ||
            ', "Quantity_return": "' || IFNULL(quantity_return, '') || '"' ||
            ', "individual_discount": "' || IFNULL(individual_discount, '') || '"' ||
            '}' AS json_str
          FROM return_items
        )
        GROUP BY date
      ),

     purchase_list_grouped AS (
        SELECT 
          DATE(created_at) AS date,
          '[' || GROUP_CONCAT(
            '{ "purchase_list": ' || purchase_list ||
            ', "return_list": ' || return_list ||
            ', "return_fee": ' || IFNULL(return_fee, 0) ||
            ', "price_type": "' || price_type || '" }'
          , ',') || ']' AS purchase_list_json,
          SUM(return_fee) AS return_fee,
          COUNT(*) AS total_invoices
        FROM invoices
        WHERE remove_at IS NULL
        GROUP BY DATE(created_at)
      )

    SELECT
      d.date AS created_at,
      plg.purchase_list_json,
      plg.return_fee,

      COALESCE(pc_cash.total, 0) AS total_cash,
      COALESCE(pc_transfer.total, 0) AS total_transfer,
      COALESCE(pd_cash.total, 0) AS total_debt_cash,
      COALESCE(pd_transfer.total, 0) AS total_debt_transfer,
      COALESCE(ps_cash.total, 0) AS total_sales_cash,
      COALESCE(ps_transfer.total, 0) AS total_sales_transfer,
      COALESCE(oc.total, 0) AS total_operating_cost,
      rij.return_items,

      COALESCE(plg.total_invoices, 0) AS total_invoices

    FROM all_dates d

    LEFT JOIN purchase_list_grouped plg ON plg.date = d.date
    LEFT JOIN payments_aggregated pc_cash ON pc_cash.date = d.date AND pc_cash.method = 'cash'
    LEFT JOIN payments_aggregated pc_transfer ON pc_transfer.date = d.date AND pc_transfer.method = 'transfer'
    LEFT JOIN payments_debt_aggregated pd_cash ON pd_cash.date = d.date AND pd_cash.method = 'cash'
    LEFT JOIN payments_debt_aggregated pd_transfer ON pd_transfer.date = d.date AND pd_transfer.method = 'transfer'
    LEFT JOIN payments_sales_aggregated ps_cash ON ps_cash.date = d.date AND ps_cash.method = 'cash'
    LEFT JOIN payments_sales_aggregated ps_transfer ON ps_transfer.date = d.date AND ps_transfer.method = 'transfer'
    LEFT JOIN operating_costs_aggregated oc ON oc.date = d.date
    LEFT JOIN return_items_json_grouped rij ON rij.date = d.date

    WHERE d.date BETWEEN ? AND ?
    GROUP BY d.date
    ORDER BY d.date DESC;
    ''';

    List<dynamic> params = [];

    final startDate = pickerDateRange.startDate!;
    final endDate = pickerDateRange.endDate!;
    params.add(DateFormat('yyyy-MM-dd').format(startDate));
    params.add(DateFormat('yyyy-MM-dd')
        .format(endDate.add(Duration(days: 1)).subtract(Duration(seconds: 1))));

    if (paid != null) {
      params.add(paid ? 1 : 0);
    }

    List<Map<String, dynamic>> results = await db.getAll(purchaseQuery, params);
    developer.log('---- results ----');
    developer.log('results $results');
    developer.log('results ${results.length}');
    developer.log('results start: $startDate end: $endDate');

    var chartList = await compute(convertToChartModel, results);

    print('results chartList ${chartList.length}');
    List<Chart> completeData = fillMissingDates(chartList, startDate, endDate);
    print('results chartList ${completeData.length}');

    return completeData;
    // return [];
  }
  // Future<List<Chart>> getChartList(PickerDateRange pickerDateRange,
  //     {bool? paid}) async {
  //   String query = '''
  //   WITH all_dates AS (
  //         SELECT DISTINCT DATE(created_at) AS created_date FROM invoices
  //         UNION
  //         SELECT DISTINCT DATE(created_at) AS created_date FROM operating_costs
  //         UNION
  //         SELECT DISTINCT DATE(created_at) AS created_date FROM invoices_sales
  //         UNION
  //         SELECT DISTINCT DATE(date) AS created_date FROM payments
  //         UNION
  //         SELECT DISTINCT DATE(date) AS created_date FROM payments_sales
  //       ),
  //       payments_summary AS (
  //           SELECT
  //               i.invoice_id,
  //               DATE(i.created_at) AS payment_date,
  //               SUM(CASE
  //                 WHEN p.method = 'cash'
  //                 AND DATE(p.date) = DATE(i.created_at)
  //                 THEN final_amount_paid
  //                 ELSE 0
  //               END) AS total_cash,
  //               SUM(CASE
  //                 WHEN p.method = 'transfer'
  //                 AND DATE(p.date) = DATE(i.created_at)
  //                 THEN final_amount_paid
  //                 ELSE 0
  //               END) AS total_transfer
  //           FROM payments p
  //           JOIN invoices i ON p.invoice_id = i.invoice_id
  //           GROUP BY payment_date
  //       ),
  //       purchases AS (
  //         SELECT
  //             i.invoice_id,
  //             DATE(i.created_at) AS created_date,

  //             p.total_cash as total_cash,
  //             p.total_transfer as total_transfer,

  //             SUM(
  //                 json_extract(value, '\$.quantity') *
  //                 CASE
  //                   WHEN i.price_type = 1 THEN json_extract(value, '\$.product.sell_price1')
  //                   WHEN i.price_type = 2 THEN json_extract(value, '\$.product.sell_price2')
  //                   WHEN i.price_type = 3 THEN json_extract(value, '\$.product.sell_price3')
  //                   ELSE json_extract(value, '\$.product.sell_price1')
  //                 END
  //             ) AS bill,
  //             SUM(
  //                 json_extract(value, '\$.quantity') *
  //                 json_extract(value, '\$.product.cost_price')
  //             ) AS cost,
  //             SUM(
  //                 json_extract(value, '\$.individual_discount')
  //             ) AS individual_discount,
  //             COALESCE(json_extract(json_extract(json(purchase_list), '\$'), '\$.bundle_discount'), 0) AS bundle_discount,

  //             SUM(
  //                 json_extract(value, '\$.Quantity_return') *
  //                 CASE
  //                   WHEN i.price_type = 1 THEN json_extract(value, '\$.product.sell_price1')
  //                   WHEN i.price_type = 2 THEN json_extract(value, '\$.product.sell_price2')
  //                   WHEN i.price_type = 3 THEN json_extract(value, '\$.product.sell_price3')
  //                   ELSE json_extract(value, '\$.product.sell_price1')
  //                 END
  //             ) AS purchase_return,
  //             i.return_fee AS return_fee
  //         FROM invoices i
  //         LEFT JOIN payments_summary p ON i.invoice_id = p.invoice_id
  //         JOIN json_each(json_extract(json(i.purchase_list), '\$'), '\$.items')
  //         WHERE i.remove_at IS NULL
  //         GROUP BY i.invoice_id
  //       ),

  //       purchase_by_date AS (
  //         SELECT
  //           DATE(created_date) AS created_date,
  //           SUM(bill) AS total_bill,
  //           SUM(cost) AS total_cost,
  //           SUM(purchase_return) AS purchase_return,
  //           SUM(return_fee) AS return_fee,
  //           SUM(individual_discount + bundle_discount) AS total_discount
  //         FROM purchases
  //         GROUP BY created_date
  //       ),

  //       additional_return AS (
  //         SELECT
  //             i.invoice_id,
  //             DATE(i.created_at) AS created_date,

  //             SUM(
  //                 json_extract(value, '\$.Quantity_return') *
  //                 CASE
  //                   WHEN i.price_type = 1 THEN json_extract(value, '\$.product.sell_price1')
  //                   WHEN i.price_type = 2 THEN json_extract(value, '\$.product.sell_price2')
  //                   WHEN i.price_type = 3 THEN json_extract(value, '\$.product.sell_price3')
  //                   ELSE json_extract(value, '\$.product.sell_price1')
  //                 END
  //             ) AS additional_return
  //         FROM invoices i
  //         JOIN json_each(json_extract(json(i.return_list), '\$'), '\$.items')
  //         WHERE i.remove_at IS NULL
  //         GROUP BY i.invoice_id
  //       ),

  //       additional_return_by_date AS (
  //         SELECT
  //           DATE(created_date) AS created_date,
  //           SUM(additional_return) AS additional_return
  //         FROM additional_return
  //         GROUP BY created_date
  //       ),

  //       cost_summary AS (
  //         SELECT
  //           DATE(created_at) AS created_date,
  //           SUM(amount) AS total_operating_cost
  //         FROM operating_costs
  //         GROUP BY DATE(created_at)
  //       ),

  //       payments_sales_summary AS (
  //         SELECT
  //           DATE(ps.date) AS created_date,
  //           SUM(CASE WHEN ps.method = 'cash'
  //           THEN ps.final_amount_paid ELSE 0 END)
  //           AS total_sales_cash,
  //           SUM(CASE WHEN ps.method = 'transfer'
  //           THEN ps.final_amount_paid ELSE 0 END)
  //           AS total_sales_transfer
  //         FROM payments_sales ps
  //         GROUP BY DATE(ps.date)
  //       ),

  //       payments_debt_summary AS (
  //         SELECT
  //           DATE(p.date) AS created_date,
  //           SUM(CASE WHEN p.method = 'cash' THEN p.final_amount_paid ELSE 0 END) AS total_debt_cash,
  //           SUM(CASE WHEN p.method = 'transfer' THEN p.final_amount_paid ELSE 0 END) AS total_debt_transfer
  //         FROM payments p
  //         JOIN invoices i ON p.invoice_id = i.invoice_id
  //         WHERE DATE(p.date) > DATE(i.created_at)
  //         GROUP BY DATE(p.date)
  //       )

  //   SELECT
  //       ad.created_date,
  //       COUNT(DISTINCT i.invoice_id) AS total_invoices,
  //       COALESCE(pd.total_bill + pd.purchase_return, 0) AS total_bill,
  //       COALESCE(pd.total_cost, 0) AS total_cost,
  //       COALESCE(pd.total_discount, 0) AS total_discount,
  //       COALESCE(pd.purchase_return, 0) AS purchase_return,
  //       COALESCE(pd.return_fee, 0) AS return_fee,
  //       COALESCE(ard.additional_return, 0) AS additional_return,

  //       COALESCE(purchase.total_cash, 0) AS total_cash,
  //       COALESCE(purchase.total_transfer, 0) AS total_transfer,

  //       COALESCE(c.total_operating_cost, 0) AS operating_cost_cash,

  //       COALESCE(p_sales.total_sales_cash, 0) AS total_sales_cash,
  //       COALESCE(p_sales.total_sales_transfer, 0) AS total_sales_transfer,

  //       COALESCE(p_debt.total_debt_cash, 0) AS total_debt_cash,
  //       COALESCE(p_debt.total_debt_transfer, 0) AS total_debt_transfer

  //   FROM all_dates ad
  //   LEFT JOIN invoices i ON ad.created_date = DATE(i.created_at)
  //   LEFT JOIN purchase_by_date pd ON ad.created_date = DATE(pd.created_date)
  //   LEFT JOIN additional_return_by_date ard ON ad.created_date = DATE(ard.created_date)
  //   LEFT JOIN purchases purchase ON ad.created_date = DATE(purchase.created_date)
  //   LEFT JOIN cost_summary c ON ad.created_date = DATE(c.created_date)
  //   LEFT JOIN payments_sales_summary p_sales ON ad.created_date = p_sales.created_date
  //   LEFT JOIN payments_debt_summary p_debt ON ad.created_date = p_debt.created_date
  //   WHERE ad.created_date BETWEEN ? AND ?
  //   GROUP BY ad.created_date
  //   ORDER BY ad.created_date;
  //   ''';

  //   List<dynamic> params = [];

  //   final startDate = pickerDateRange.startDate!;
  //   final endDate = pickerDateRange.endDate!;
  //   params.add(DateFormat('yyyy-MM-dd').format(startDate));
  //   params.add(DateFormat('yyyy-MM-dd').format(endDate));

  //   List<Map<String, dynamic>> results = await db.getAll(query, params);
  //   developer.log('---- results ----');
  //   developer.log('results $results');
  //   developer.log('results ${results.length}');
  //   developer.log('results start: $startDate end: $endDate');

  //   var chartList = await compute(convertToChartModel, results);

  //   print('results chartList ${chartList.length}');
  //   List<Chart> completeData = fillMissingDates(chartList, startDate, endDate);

  //   return completeData;
  //   // return [];
  // }

  List<Chart> fillMissingDates(
      List<Chart> data, DateTime startDate, DateTime endDate) {
    List<Chart> chartList = [];
    DateTime currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      bool dateExists = false;
      print('results -----');
      print('results currentDate ${currentDate}');
      print('results endDate ${endDate}');
      print('results chart ${data.length}');
      print('results newChartList ${chartList.length}');

      for (var chart in data) {
        if (DateFormat('yyyy-MM-dd').format(chart.date) ==
            DateFormat('yyyy-MM-dd').format(currentDate)) {
          dateExists = true;
          break;
        }
      }
      if (!dateExists) {
        chartList.add(Chart(
            date: currentDate,
            dateDisplay: dateWihtoutTime.format(currentDate)));
      }
      currentDate = currentDate.add(const Duration(days: 1));
      print('results currentDate update ${currentDate}');
      print('results update ChartList ${chartList.length}');
    }
    chartList.addAll(data);
    print('results chartList final ${chartList.length}');
    return chartList.toList();
  }
}
