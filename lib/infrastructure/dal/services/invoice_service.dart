import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../domain/core/interfaces/invoice_repository.dart';
import '../../models/invoice_model/invoice_model.dart';
import '../../models/payment_model.dart';
import '../database/powersync.dart';

class InvoiceService extends GetxService implements InvoiceRepository {
  // var invoices = <InvoiceModel>[].obs;
  var paidInv = <InvoiceModel>[].obs;
  var debtInv = <InvoiceModel>[].obs;
  var filteredPaidInv = <InvoiceModel>[].obs;
  var filteredDebtInv = <InvoiceModel>[].obs;
  // var monthlyInvoice = <InvoiceModel>[].obs;
  var displayedInvoices = <InvoiceModel>[].obs;

  // var CashPayment = <InvoiceModel>[].obs;
  // var displayedInvoices = <InvoiceModel>[].obs;

  var searchQuery = ''.obs;
  var searchDateQuery = Rx<PickerDateRange?>(null);
  var methodPayment = ''.obs;
  var changeCount = 0.obs;

  late Stream<List<InvoiceModel>> paidInvStream;
  late Stream<List<InvoiceModel>> debtInvStream;

  @override
  Future<void> subscribe(String storeId) async {
    //! paid invoice
    final startTime = DateTime.now();
    paidInvStream = db.watch('''
      SELECT * 
      FROM invoices 
      WHERE remove_at IS NULL AND is_debt_paid = 1
      ORDER BY created_at DESC
      ''').map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    paidInvStream.listen((datas) {
      paidInv.value = datas;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Waktu pengambilan data paidInv: ${duration.inMilliseconds} ms');
    });

    //! debt invoice
    final startTimeDebt = DateTime.now();
    debtInvStream = db.watch('''
      SELECT * 
      FROM invoices 
      WHERE remove_at IS NULL AND is_debt_paid = 0
      ORDER BY created_at DESC
      ''').map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    debtInvStream.listen((datas) {
      debtInv.value = datas;
      final endTime = DateTime.now();
      final duration = endTime.difference(startTimeDebt);
      print('Waktu pengambilan data debtInv: ${duration.inMilliseconds} ms');
    });
  }

  // Fungsi untuk menerapkan filter dan pencarian
  Future<void> applyFilters() async {
    var paidInvResult = <InvoiceModel>[].obs;
    var debtInvResult = <InvoiceModel>[].obs;

    if (searchDateQuery.value != null) {
      paidInvResult.value =
          await getByCreatedDate(searchDateQuery.value!, paid: true);
      debtInvResult.value =
          await getByCreatedDate(searchDateQuery.value!, paid: false);
    }

    if (methodPayment.value.isNotEmpty && searchDateQuery.value == null) {
      paidInvResult.value =
          await searchByPaymentMethod(methodPayment.value, true);
      debtInvResult.value =
          await searchByPaymentMethod(methodPayment.value, false);
    }

    if (searchQuery.value.isNotEmpty) {
      if (searchDateQuery.value != null || methodPayment.value.isNotEmpty) {
        if (searchDateQuery.value != null) {
          var paid = paidInvResult
              .where((invoice) =>
                  invoice.customer.value!.name
                      .toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ||
                  invoice.invoiceId!
                      .toLowerCase()
                      .contains(searchQuery.value.toLowerCase()))
              .toList();
          var debt = debtInvResult
              .where((invoice) =>
                  invoice.customer.value!.name
                      .toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ||
                  invoice.invoiceId!
                      .toLowerCase()
                      .contains(searchQuery.value.toLowerCase()))
              .toList();
          paidInvResult.value = paid;
          debtInvResult.value = debt;
        }
        if (methodPayment.value.isNotEmpty) {
          var paid = paidInvResult
              .where((invoice) =>
                  (invoice.customer.value!.name
                          .toLowerCase()
                          .contains(searchQuery.value.toLowerCase()) ||
                      invoice.invoiceId!
                          .toLowerCase()
                          .contains(searchQuery.value.toLowerCase())) &&
                  invoice.payments.any((payment) => payment.method!
                      .toLowerCase()
                      .contains(methodPayment.value.toLowerCase())))
              .toList();
          var debt = debtInvResult
              .where((invoice) =>
                  (invoice.customer.value!.name
                          .toLowerCase()
                          .contains(searchQuery.value.toLowerCase()) ||
                      invoice.invoiceId!
                          .toLowerCase()
                          .contains(searchQuery.value.toLowerCase())) &&
                  invoice.payments.any((payment) => payment.method!
                      .toLowerCase()
                      .contains(methodPayment.value.toLowerCase())))
              .toList();
          paidInvResult.value = paid;
          debtInvResult.value = debt;
        }
      } else {
        paidInvResult.value = await searchInv(searchQuery.value, true);
        debtInvResult.value = await searchInv(searchQuery.value, false);
      }
    }

    filteredPaidInv.value = paidInvResult
      ..sort((a, b) => DateTime.parse(b.createdAt.value!.toIso8601String())
          .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
    filteredDebtInv.value = debtInvResult
      ..sort((a, b) => DateTime.parse(b.createdAt.value!.toIso8601String())
          .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
  }

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
      ''';
    List<Map<String, dynamic>> results = await db.getAll(query, [
      DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
      DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
    ]);
    if (paid != null) {
      results = results.where((element) {
        // print('results ${element}');
        return element['is_debt_paid'] == (paid ? 1 : 0);
      }).toList();
      print('results ${results.length}');
    }
    var invoiceList = results.map((e) => InvoiceModel.fromJson(e)).toList();
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

  //   @override
  // Future<List<InvoiceModel>> getByCreatedDate(DateTime startOfDate) async {
  //   DateTime endOfDate = startOfDate.add(Duration(days: 7));
  //   String query = '''
  //     SELECT * FROM invoices WHERE
  //     created_at BETWEEN ? AND ?
  //     ''';
  //   List<Map<String, dynamic>> results = await db.getAll(query, [
  //     DateFormat('yyyy-MM-dd').format(startOfDate),
  //     DateFormat('yyyy-MM-dd').format(endOfDate),
  //   ]);
  //   var invoiceList = results.map((e) => InvoiceModel.fromJson(e)).toList();
  //   print('created at $invoiceList');
  //   return invoiceList;
  // }

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

  Future<List<PaymentMapModel>> getPaymentByDate(
      PickerDateRange pickerDateRange) async {
    String query =
        'SELECT id, created_at, payments FROM invoices WHERE remove_at IS NULL AND created_at BETWEEN ? AND ?';

    List<Map<String, dynamic>> results = await db.getAll(query, [
      DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
      DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
    ]);
    return results.map((e) => PaymentMapModel.fromJson(e)).toList();
  }

  Future<List<PaymentMapModel>> getAllPayment() async {
    List<Map<String, dynamic>> results = await db.getAll(
        'SELECT id, created_at, payments FROM invoices WHERE remove_at IS NULL');
    return results.map((e) => PaymentMapModel.fromJson(e)).toList();
  }

  @override
  Future<void> insert(InvoiceModel invoice) async {
    await db.execute(
      '''
    INSERT INTO invoices(
      id, store_id, invoice_id, account, created_at, customer, purchase_list,
      return_list, after_return_list, price_type, discount, tax, return_fee,
      payments, remove_product, debt_amount, app_bill_amount, is_debt_paid, is_app_bill_paid, other_costs, init_at, remove_at
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
        jsonEncode(updatedInvoice.account.value
            .toJson()), // Convert Map to JSON string
        updatedInvoice.createdAt.value?.toIso8601String(),
        jsonEncode(updatedInvoice.customer.value
            ?.toJson()), // Convert Map to JSON string
        jsonEncode(updatedInvoice.purchaseList.value
            .toJson()), // Convert Map to JSON string
        jsonEncode(updatedInvoice.returnList.value
            ?.toJson()), // Convert Map to JSON string
        updatedInvoice.afterReturnList.value != null
            ? jsonEncode(updatedInvoice.afterReturnList.value?.toJson())
            : null,
        updatedInvoice.priceType.value,
        updatedInvoice.discount.value,
        updatedInvoice.tax.value,
        updatedInvoice.returnFee.value,
        jsonEncode(updatedInvoice.payments
            .map((e) => e.toJson())
            .toList()), // Convert list of Maps to JSON string
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
      parameterSets,
    );
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
    } catch (e) {
      e.toString();
    }
  }
}
