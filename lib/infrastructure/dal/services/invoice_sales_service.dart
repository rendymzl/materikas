import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/invoice_sales_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../domain/core/interfaces/invoice_sales_repository.dart';
import '../database/powersync.dart';

class InvoiceSalesService extends GetxService
    implements InvoiceSalesRepository {
  var invoices = <InvoiceSalesModel>[].obs;
  var foundInvoices = <InvoiceSalesModel>[].obs;

  @override
  void onInit() async {
    super.onInit();
  }

  void searchInvoicesByName(String invoiceName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceName == '') {
        DateTime sevenDaysAgo =
            DateTime.now().subtract(const Duration(days: 7));

        List<InvoiceSalesModel> subList = invoices.where((invoice) {
          return invoice.createdAt.value!.isAfter(sevenDaysAgo);
        }).toList();
        List<InvoiceSalesModel> sortInvoice = sortByDate(subList);
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      } else {
        List<InvoiceSalesModel> sortList = invoices.where((invoice) {
          return invoice.invoiceId!
              .toLowerCase()
              .contains(invoiceName.toLowerCase());
        }).toList();
        List<InvoiceSalesModel> sortInvoice = sortByDate(sortList);
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      }
    });
  }

  void searchInvoicesByPickerDateRange(PickerDateRange? invoiceCreatedAt) {
    if (invoiceCreatedAt != null) {
      foundInvoices.clear();
      foundInvoices.value = invoices.where((invoice) {
        if (invoice.createdAt.value != null) {
          DateTime invoiceDate = invoice.createdAt.value!;
          return invoiceDate.isAfter(invoiceCreatedAt.startDate!) &&
              invoiceDate.isBefore(invoiceCreatedAt.endDate!);
        }
        return false;
      }).toList();
    } else {
      searchInvoicesByName('');
    }
    // });
  }

  List<InvoiceSalesModel> sortByDate(List<InvoiceSalesModel> invoicesList) {
    invoicesList
        .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
    return invoicesList;
  }

  @override
  Future<void> subscribe(String storeId) async {
    try {
      var stream = db.watch('SELECT * FROM invoices_sales WHERE store_id = ?',
          parameters: [
            storeId
          ]).map((data) =>
          data.map((json) => InvoiceSalesModel.fromJson(json)).toList());

      stream.listen((update) {
        invoices.assignAll(update);
        searchInvoicesByName('');
      });
    } on PostgrestException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  @override
  Future<void> insert(InvoiceSalesModel invoice) async {
    await db.execute(
      '''
    INSERT INTO invoices_sales(
      id, store_id, invoice_id, created_at, sales, purchase_list, discount, tax,
      payments, debt_amount, is_debt_paid
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        // invoice.id,
        invoice.storeId,
        invoice.invoiceId,
        invoice.createdAt.value?.toIso8601String(),
        invoice.sales.value,
        invoice.purchaseList.value.toJson(),
        invoice.discount.value,
        invoice.tax.value,
        invoice.payments.map((e) => e.toJson()).toList(),
        invoice.debtAmount.value,
        invoice.isDebtPaid.value ? 1 : 0,
      ],
    );
  }

  @override
  Future<void> update(InvoiceSalesModel updatedInvoice) async {
    await db.execute(
      '''
    UPDATE invoices_sales SET
      store_id = ?, 
      invoice_id = ?, 
      created_at = ?, 
      sales = ?, 
      purchase_list = ?, 
      discount = ?, 
      tax = ?, 
      payments = ?, 
      debt_amount = ?, 
      is_debt_paid = ?
    WHERE id = ?
    ''',
      [
        updatedInvoice.storeId,
        updatedInvoice.invoiceId,
        updatedInvoice.createdAt.value?.toIso8601String(),
        updatedInvoice.sales.value,
        updatedInvoice.purchaseList.value.toJson(),
        updatedInvoice.discount.value,
        updatedInvoice.tax.value,
        updatedInvoice.payments.map((e) => e.toJson()).toList(),
        updatedInvoice.debtAmount.value,
        updatedInvoice.isDebtPaid.value ? 1 : 0,
        updatedInvoice.id,
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      '''
    DELETE FROM invoices_sales WHERE id = ?
    ''',
      [id],
    );
  }
}
