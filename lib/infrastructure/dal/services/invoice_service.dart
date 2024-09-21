import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  var searchQuery = ''.obs;

  late Stream<List<InvoiceModel>> stream;

  @override
  Future<void> subscribe(String storeId) async {
    //! streamCount

    // var streamPayCash = db
    //     .watch("SELECT * FROM invoices WHERE store_id = ? AND json_extract(data, '$.details.city') = ?", parameters: [
    //   storeId,
    //   storeId
    // ]).map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    // streamPayCash.listen((datas) {
    //   paidInv.clear();
    //   debtInv.clear();
    //   for (var invoice in datas) {
    //     if (invoice.totalPaid >= invoice.totalBill) {
    //       paidInv.add(InvoiceModel.fromJson(invoice.toJson()));
    //     } else {
    //       debtInv.add(InvoiceModel.fromJson(invoice.toJson()));
    //     }
    //   }

    //   // invoices.value = data;
    //   applyFilters();
    // });
    //! paid invoice
    var streamPaidInv = db.watch('''
      SELECT * FROM invoices WHERE store_id = ? AND is_debt_paid = true
      ''', parameters: [
      storeId
    ]).map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    streamPaidInv.listen((datas) {
      paidInv.clear();
      paidInv.value = datas;
      paidInv.sort((a, b) =>
          DateTime.parse(b.createdAt.value!.toIso8601String())
              .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
    });

    //! debt invoice
    var streamDebtInv = db.watch('''
      SELECT * FROM invoices WHERE store_id = ? AND is_debt_paid = false
      ''', parameters: [
      storeId
    ]).map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    streamDebtInv.listen((datas) {
      debtInv.clear();
      debtInv.value = datas;
      debtInv.sort((a, b) =>
          DateTime.parse(b.createdAt.value!.toIso8601String())
              .compareTo(DateTime.parse(a.createdAt.value!.toIso8601String())));
    });

    // var streamPaymentCash = db.watch('''
    //   SELECT * FROM invoices WHERE store_id = ? AND json_extract(data, '\$.method.city') = 'cash'
    //   ''', parameters: [
    //   storeId
    // ]).map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    // streamPaymentCash.listen((datas) {
    //   paidInv.clear();
    //   debtInv.clear();
    //   for (var invoice in datas) {
    //     if (invoice.totalPaid >= invoice.totalBill) {
    //       paidInv.add(InvoiceModel.fromJson(invoice.toJson()));
    //     } else {
    //       debtInv.add(InvoiceModel.fromJson(invoice.toJson()));
    //     }
    //   }

    //   // invoices.value = data;
    //   applyFilters();
    // });

    // var stream = db
    //     .watch('SELECT * FROM invoices WHERE store_id = ?', parameters: [
    //   storeId
    // ]).map((data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

    // stream.listen((datas) {
    //   paidInv.clear();
    //   debtInv.clear();
    //   for (var invoice in datas) {
    //     if (invoice.isDebtPaid.value) {
    //       paidInv.add(InvoiceModel.fromJson(invoice.toJson()));
    //     } else {
    //       debtInv.add(InvoiceModel.fromJson(invoice.toJson()));
    //     }
    //   }
    //   print('paidInv ${paidInv.length}');
    //   print('debtInv ${debtInv.length}');
    //   // invoices.value = data;
    //   // applyFilters();
    // });
  }

  // Fungsi untuk menerapkan filter dan pencarian
  void applyFilters() async {
    var paidInvResult = paidInv;
    var debtInvResult = debtInv;

    // Filter berdasarkan kategori jika ada yang dipilih
    // if (selectedCategory.value.isNotEmpty) {
    //   result = result.where((product) {
    //     return product['category'] == selectedCategory.value;
    //   }).toList().obs;
    // }

    // Filter berdasarkan pencarian (misal mencari berdasarkan nama produk)
    if (searchQuery.value.isNotEmpty) {
      paidInvResult.value = await searchInv(searchQuery.value, true);
      debtInvResult.value = await searchInv(searchQuery.value, false);
      // paidInvResult = paidInv
      //     .where((inv) {
      //       return inv.invoiceId!
      //               .toLowerCase()
      //               .contains(searchQuery.toLowerCase()) ||
      //           inv.customer.value!.name
      //               .toLowerCase()
      //               .contains(searchQuery.toLowerCase());
      //     })
      //     .toList()
      //     .obs;
      // debtInvResult = debtInv
      //     .where((inv) {
      //       return inv.invoiceId!
      //               .toLowerCase()
      //               .contains(searchQuery.toLowerCase()) ||
      //           inv.customer.value!.name
      //               .toLowerCase()
      //               .contains(searchQuery.toLowerCase());
      //     })
      //     .toList()
      //     .obs;
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
      invoice_id LIKE ? AND  OR
      json_extract(data, '\$.customer.name') LIKE ?
      ''';
    List<Map<String, dynamic>> results =
        await db.getAll(query, ['%$searchTerm%', '%$searchTerm%']);

    return results.map((e) => InvoiceModel.fromJson(e)).toList();
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
        invoice.account.value,
        invoice.createdAt.value?.toIso8601String(),
        invoice.customer.value?.toJson(),
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
      print('updateddddddddddddddddddddd');
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
          updatedInvoice.account.value,
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
