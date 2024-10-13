import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materikas/infrastructure/models/payment_model.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../domain/core/interfaces/invoice_repository.dart';
import '../../models/invoice_model/invoice_model.dart';
import '../database/powersync.dart';

class InvoiceService extends GetxService implements InvoiceRepository {
  // var invoices = <InvoiceModel>[].obs;
  var paidInv = <InvoiceModel>[].obs;
  var debtInv = <InvoiceModel>[].obs;
  var filteredPaidInv = <InvoiceModel>[].obs;
  var filteredDebtInv = <InvoiceModel>[].obs;
  var displayedInvoices = <InvoiceModel>[].obs;

  // var CashPayment = <InvoiceModel>[].obs;
  // var displayedInvoices = <InvoiceModel>[].obs;

  var searchQuery = ''.obs;
  var searchDateQuery = Rx<PickerDateRange?>(null);
  var changeCount = 0.obs;

  late Stream<List<InvoiceModel>> stream;

  @override
  Future<void> subscribe(String storeId) async {
    //! paid invoice
    var streamPaidInv = db.watch('''
      SELECT * FROM invoices WHERE store_id = ? AND is_debt_paid = true ORDER BY created_at DESC LIMIT 100
      ''', parameters: [
      storeId
    ]).map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    streamPaidInv.listen((datas) {
      print('paidInv.length: ${datas.length}');
      paidInv.clear();
      paidInv.value = datas;
      paidInv.sort((a, b) =>
          DateTime.parse(b.createdAt.value!.toIso8601String())
              .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
      changeCount.value++;
    });

    //! debt invoice
    var streamDebtInv = db.watch('''
      SELECT * FROM invoices WHERE store_id = ? AND is_debt_paid = false
      ''', parameters: [
      storeId
    ]).map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    streamDebtInv.listen((datas) {
      print('debtInv.length: ${datas.length}');
      debtInv.clear();
      debtInv.value = datas;
      debtInv.sort((a, b) =>
          DateTime.parse(b.createdAt.value!.toIso8601String())
              .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
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

    // Filter berdasarkan pencarian (misal mencari berdasarkan nama produk)
    if (searchQuery.value.isNotEmpty) {
      if (searchDateQuery.value != null) {
              paidInvResult.where((invoice) => invoice.in.toLowerCase().contains(searchQuery.value.toLowerCase()) || invoice.invoiceId.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();

      } else {
        paidInvResult.value = await searchInv(searchQuery.value, true);
        debtInvResult.value = await searchInv(searchQuery.value, false);
      }
    }

    // Update produk yang sudah difilter
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
        ''';
    List<Map<String, dynamic>> results = await db.getAll(query, [
      '%${searchTerm.toLowerCase()}%',
      '%${searchTerm.toLowerCase()}%',
      paid,
    ]);
    return results.map((e) => InvoiceModel.fromJson(e)).toList();
  }

  @override
  Future<List<InvoiceModel>> getByCreatedDate(PickerDateRange pickerDateRange,
      {bool? paid}) async {
    if (paid != null) {
      String query = '''
      SELECT * FROM invoices WHERE
      is_debt_paid = ? AND
      created_at BETWEEN ? AND ?
      ''';
      List<Map<String, dynamic>> results = await db.getAll(query, [
        paid,
        DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
        DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
      ]);
      var invoiceList = results.map((e) => InvoiceModel.fromJson(e)).toList();
      return invoiceList;
    } else {
      String query = '''
      SELECT * FROM invoices WHERE
      created_at BETWEEN ? AND ?
      ''';
      List<Map<String, dynamic>> results = await db.getAll(query, [
        DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
        DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
      ]);
      var invoiceList = results.map((e) => InvoiceModel.fromJson(e)).toList();
      return invoiceList;
    }
  }
  // @override
  // Future<List<InvoiceModel>> getByCreatedDate(DateTime startOfDate) async {
  //   String query = '''
  //     SELECT * FROM invoices WHERE
  //     DATE(created_at) LIKE ?
  //     ''';
  //   List<Map<String, dynamic>> results = await db.getAll(query, [
  //     '%${DateFormat('yyyy-MM-dd').format(startOfDate)}%',
  //   ]);
  //   var invoiceList = results.map((e) => InvoiceModel.fromJson(e)).toList();
  //   return invoiceList;
  // }

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

  @override
  Future<void> insert(InvoiceModel invoice) async {
    await db.execute(
      '''
    INSERT INTO invoices(
      id, store_id, invoice_id, account, created_at, customer, purchase_list,
      return_list, after_return_list, price_type, discount, tax, return_fee,
      payments, debt_amount, is_debt_paid, other_costs
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
        invoice.debtAmount.value,
        invoice.isDebtPaid.value ? 1 : 0,
        invoice.otherCosts.map((e) => e.toJson()).toList(),
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
      debt_amount = ?, 
      is_debt_paid = ?, 
      other_costs = ?
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
          updatedInvoice.debtAmount.value,
          updatedInvoice.isDebtPaid.value ? 1 : 0,
          updatedInvoice.otherCosts.map((e) => e.toJson()).toList(),
          updatedInvoice.id,
        ],
      );
    } catch (e) {
      e.toString();
    }
  }

  @override
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM invoices WHERE id = ?', [id]);
  }
}
