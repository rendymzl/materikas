import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../domain/core/interfaces/invoice_repository.dart';
import '../../models/invoice_model/invoice_model.dart';
import '../database/powersync.dart';

class InvoiceService extends GetxService implements InvoiceRepository {
  var invoices = <InvoiceModel>[].obs;
  var foundInvoices = <InvoiceModel>[].obs;
  var paidInv = <InvoiceModel>[].obs;
  var debtInv = <InvoiceModel>[].obs;

  void searchInvoicesByName(String invoiceName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceName == '') {
        DateTime sevenDaysAgo =
            DateTime.now().subtract(const Duration(days: 60));

        List<InvoiceModel> subList = invoices.where((invoice) {
          return invoice.createdAt.value!.isAfter(sevenDaysAgo);
        }).toList();
        List<InvoiceModel> sortInvoice = sortByDate(subList);
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      } else {
        List<InvoiceModel> sortList = invoices.where((invoice) {
          return invoice.invoiceId!
                  .toLowerCase()
                  .contains(invoiceName.toLowerCase()) ||
              invoice.customer.value!.name
                  .toLowerCase()
                  .contains(invoiceName.toLowerCase());
        }).toList();
        List<InvoiceModel> sortInvoice = sortByDate(sortList);
        foundInvoices.clear();
        foundInvoices.addAll(sortInvoice);
      }
      asignPaidDebtInv();
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
      asignPaidDebtInv();
    } else {
      searchInvoicesByName('');
    }

    // });
  }

  void asignPaidDebtInv() {
    paidInv.value = foundInvoices.where((i) {
      return i.totalPaid >= i.totalBill;
    }).map((purchased) {
      InvoiceModel invPurchase = InvoiceModel.fromJson(purchased.toJson());
      return invPurchase;
    }).toList();

    debtInv.value = foundInvoices.where((i) {
      return i.totalPaid < i.totalBill;
    }).map((purchased) {
      InvoiceModel invPurchase = InvoiceModel.fromJson(purchased.toJson());
      return invPurchase;
    }).toList();
  }

  List<InvoiceModel> sortByDate(List<InvoiceModel> invoicesList) {
    invoicesList
        .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
    return invoicesList;
  }

  @override
  Future<void> subscribe(String storeId) async {
    try {
      var stream = db.watch('SELECT * FROM invoices WHERE store_id = ?',
          parameters: [
            storeId
          ]).map(
          (data) => data.map((json) => InvoiceModel.fromJson(json)).toList());

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
        updatedInvoice.customer.value,
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
  }

  @override
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM invoices WHERE id = ?', [id]);
  }
}
