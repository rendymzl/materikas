import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materikas/infrastructure/models/invoice_sales_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../domain/core/interfaces/invoice_sales_repository.dart';
import '../../models/payment_model.dart';
import '../database/powersync.dart';

Future<List<InvoiceSalesModel>> convertToModel(
    List<Map<String, dynamic>> maps) async {
  return maps.map((e) => InvoiceSalesModel.fromJson(e)).toList();
}

class InvoiceSalesService extends GetxService
    implements InvoiceSalesRepository {
  var salesInvoices = <InvoiceSalesModel>[].obs;

  @override
  Future<void> subscribe() async {
    try {
      // String query = '''
      //   SELECT * FROM invoices_sales
      //   WHERE sales ->> 'id' = ?
      //   ORDER BY created_at DESC
      //   ''';
      String query = '''
        select
        invoices_sales.id,
        invoices_sales.store_id,
        invoices_sales.invoice_number,
        invoices_sales.invoice_name,
        invoices_sales.created_at,
        invoices_sales.sales,
        invoices_sales.purchase_list,
        invoices_sales.discount,
        invoices_sales.tax,
        invoices_sales.debt_amount,
        invoices_sales.is_debt_paid,
        invoices_sales.remove_at,
        invoices_sales.purchase_order,
        '[' || GROUP_CONCAT(
            '{ "id": "' || payments_sales.id || '"' ||
            ', "invoice_id": "' || payments_sales.invoice_number || '"' ||
            ', "store_id": "' || payments_sales.store_id || '"' ||
            ', "invoice_created_at": "' || payments_sales.invoice_created_at || '"' ||
            ', "date": "' || payments_sales.date || '"' ||
            ', "method": "' || payments_sales.method || '"' ||
            ', "final_amount_paid": ' || payments_sales.final_amount_paid ||
            ', "remain": ' || payments_sales.remain ||
            ', "amount_paid": ' || payments_sales.amount_paid || 
            '}', ', '
          ) || ']' AS payments
        FROM
          invoices_sales
        LEFT JOIN
        payments_sales ON invoices_sales.invoice_number = payments_sales.invoice_number
        WHERE invoices_sales.remove_at IS NULL
        GROUP BY
          invoices_sales.invoice_number
        ORDER BY invoices_sales.created_at DESC
        ''';
      var stream = db.watch(query);

      stream.listen((update) async {
        var invoiceList = await compute(convertToModel, update);
        salesInvoices.value = invoiceList;
      });
    } on PostgrestException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  Future<List<InvoiceSalesModel>> fetch({
    String? salesId,
    int offset = 15,
    int limit = 15,
    String search = '',
    bool? isPaid,
  }) async {
    try {
      String query = '''
        select
        invoices_sales.id,
        invoices_sales.store_id,
        invoices_sales.invoice_number,
        invoices_sales.invoice_name,
        invoices_sales.created_at,
        invoices_sales.sales,
        invoices_sales.purchase_list,
        invoices_sales.discount,
        invoices_sales.tax,
        invoices_sales.debt_amount,
        invoices_sales.is_debt_paid,
        invoices_sales.remove_at,
        invoices_sales.purchase_order,
        '[' || GROUP_CONCAT(
            '{ "id": "' || payments_sales.id || '"' ||
            ', "invoice_id": "' || payments_sales.invoice_number || '"' ||
            ', "store_id": "' || payments_sales.store_id || '"' ||
            ', "invoice_created_at": "' || payments_sales.invoice_created_at || '"' ||
            ', "date": "' || payments_sales.date || '"' ||
            ', "method": "' || payments_sales.method || '"' ||
            ', "final_amount_paid": ' || payments_sales.final_amount_paid ||
            ', "remain": ' || payments_sales.remain ||
            ', "amount_paid": ' || payments_sales.amount_paid || 
            '}', ', '
          ) || ']' AS payments
        FROM
          invoices_sales
        LEFT JOIN
        payments_sales ON invoices_sales.invoice_number = payments_sales.invoice_number
        WHERE invoices_sales.remove_at IS NULL
        ${isPaid != null ? 'AND is_debt_paid = ?' : ''}
        ${salesId != null ? 'AND invoices_sales.sales LIKE ?' : ''}
        ${search.isNotEmpty ? 'AND (invoices_sales.sales LIKE ? OR invoices_sales.invoice_name LIKE ?)' : ''}
        GROUP BY
          invoices_sales.invoice_number
        ORDER BY invoices_sales.created_at DESC
        LIMIT ? OFFSET ?
        ''';
      List<Map<String, dynamic>> results = await db.getAll(query, [
        if (isPaid != null) isPaid ? 1 : 0,
        if (salesId != null) '%$salesId%',
        // if (search.isNotEmpty) '%"name":"$search"%',
        if (search.isNotEmpty) '%$search%',
        if (search.isNotEmpty) '%$search%',
        limit,
        offset,
      ]);

      print('datasdatasdatas ${results} ${salesId}');
      if (results.isEmpty) {
        return [];
      }

      var invoiceList = await compute(convertToModel, results);
      return invoiceList;
    } on PostgrestException catch (e) {
      print(e.message);
      rethrow;
    }
  }
  // Future<List<InvoiceSalesModel>> fetchBySalesId(String salesId) async {
  //   try {
  //     // String query = '''
  //     //   SELECT * FROM invoices_sales
  //     //   WHERE sales ->> 'id' = ?
  //     //   ORDER BY created_at DESC
  //     //   ''';
  //     String query = '''
  //       select
  //       invoices_sales.id,
  //       invoices_sales.store_id,
  //       invoices_sales.invoice_number,
  //       invoices_sales.invoice_name,
  //       invoices_sales.created_at,
  //       invoices_sales.sales,
  //       invoices_sales.purchase_list,
  //       invoices_sales.discount,
  //       invoices_sales.tax,
  //       invoices_sales.debt_amount,
  //       invoices_sales.is_debt_paid,
  //       '[' || GROUP_CONCAT(
  //           '{ "id": "' || payments_sales.id || '"' ||
  //           ', "invoice_id": "' || payments_sales.invoice_number || '"' ||
  //           ', "store_id": "' || payments_sales.store_id || '"' ||
  //           ', "invoice_created_at": "' || payments_sales.invoice_created_at || '"' ||
  //           ', "date": "' || payments_sales.date || '"' ||
  //           ', "method": "' || payments_sales.method || '"' ||
  //           ', "final_amount_paid": ' || payments_sales.final_amount_paid ||
  //           ', "remain": ' || payments_sales.remain ||
  //           ', "amount_paid": ' || payments_sales.amount_paid ||
  //           '}', ', '
  //         ) || ']' AS payments
  //       FROM
  //         invoices_sales
  //       LEFT JOIN
  //       payments_sales ON invoices_sales.invoice_number = payments_sales.invoice_number
  //       WHERE invoices_sales.sales LIKE ?
  //       GROUP BY
  //         invoices_sales.invoice_number
  //       ORDER BY invoices_sales.created_at DESC
  //       ''';
  //     List<Map<String, dynamic>> results = await db.getAll(query, [
  //       '%$salesId%',
  //     ]);

  //     print('datasdatasdatas ${results} ${salesId}');
  //     if (results.isEmpty) {
  //       return [];
  //     }

  //     var invoiceList = await compute(convertToModel, results);
  //     return invoiceList;
  //   } on PostgrestException catch (e) {
  //     print(e.message);
  //     rethrow;
  //   }
  // }

  Future<List<InvoiceSalesModel>> getPaymentByDate(
      PickerDateRange pickerDateRange) async {
    try {
      String query = '''
        select
        isl.id,
        isl.store_id,
        isl.invoice_number,
        isl.invoice_name,
        isl.created_at,
        isl.sales,
        isl.purchase_list,
        isl.discount,
        isl.tax,
        isl.debt_amount,
        isl.is_debt_paid,
        isl.remove_at,
        isl.purchase_order,
        '[' || GROUP_CONCAT(
            '{ "id": "' || ps.id || '"' ||
            ', "invoice_id": "' || ps.invoice_number || '"' ||
            ', "store_id": "' || ps.store_id || '"' ||
            ', "invoice_created_at": "' || ps.invoice_created_at || '"' ||
            ', "date": "' || ps.date || '"' ||
            ', "method": "' || ps.method || '"' ||
            ', "final_amount_paid": ' || ps.final_amount_paid ||
            ', "remain": ' || ps.remain ||
            ', "amount_paid": ' || ps.amount_paid || 
            '}', ', '
          ) || ']' AS payments
        FROM payments_sales ps
        LEFT JOIN invoices_sales isl ON ps.invoice_number = isl.invoice_number
        WHERE DATE(ps.date) BETWEEN ? AND ?
        GROUP BY
          isl.invoice_number
        ORDER BY isl.created_at DESC
        ''';
      List<Map<String, dynamic>> results = await db.getAll(query, [
        DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
        DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
      ]);

      if (results.isEmpty) {
        print('lenght debug ${results}');
        return [];
      }

      var invoiceList = await compute(convertToModel, results);
      return invoiceList;
    } on PostgrestException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  Future<List<InvoiceSalesModel>> getByCreatedDate(
      PickerDateRange pickerDateRange) async {
    String query = '''
      SELECT * FROM invoices_sales WHERE
      created_at BETWEEN ? AND ?
      ''';
    List<Map<String, dynamic>> results = await db.getAll(query, [
      DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
      DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
    ]);

    var invoiceList = await compute(convertToModel, results);
    return invoiceList;
  }

  // Future<List<InvoiceSalesModel>> getByPaymentDate(
  //     PickerDateRange pickerDateRange) async {
  //   String query = '''
  //     SELECT * FROM invoices_sales WHERE
  //     created_at BETWEEN ? AND ?
  //     ''';
  //   List<Map<String, dynamic>> results = await db.getAll(query, [
  //     DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
  //     DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
  //   ]);

  //   var invoiceList = await compute(convertToModel, results);
  //   return invoiceList;
  // }

  @override
  Future<void> insert(InvoiceSalesModel invoice) async {
    print('paymentInsert ${invoice.toJson()}');
    await db.execute(
      '''
    INSERT INTO invoices_sales(
      id, store_id, invoice_number, invoice_name, created_at, sales, purchase_list, discount, tax,
      payments, debt_amount, is_debt_paid, remove_at, purchase_order
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        // invoice.id,
        invoice.storeId,
        invoice.invoiceNumber,
        invoice.invoiceName.value,
        invoice.createdAt.value?.toIso8601String(),
        invoice.sales.value,
        invoice.purchaseList.value.toJson(),
        invoice.discount.value,
        invoice.tax.value,
        invoice.payments.map((e) => e.toJson()).toList(),
        invoice.debtAmount.value,
        invoice.isDebtPaid.value ? 1 : 0,
        invoice.removeAt.value?.toIso8601String(),
        invoice.purchaseOrder.value ? 1 : 0,
      ],
    );

    await insertListPayments(invoice.payments);
  }

  Future<void> insertListPayments(List<PaymentModel> paymentList) async {
    final List<List<Object?>> parameterSets = paymentList.map((payment) {
      print('paymentInsert 2 ${payment.toJson()}');
      return [
        payment.invoiceId!,
        payment.storeId,
        payment.invoiceCreatedAt!.toIso8601String(),
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
    INSERT INTO payments_sales(
      id, invoice_number, store_id, invoice_created_at, date, remove_at, amount_paid, method, final_amount_paid, remain
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      parameterSets,
    );
  }

  @override
  Future<void> update(InvoiceSalesModel updatedInvoice) async {
    await db.execute(
      '''
    UPDATE invoices_sales SET
      store_id = ?, 
      invoice_number = ?, 
      invoice_name = ?, 
      created_at = ?, 
      sales = ?, 
      purchase_list = ?, 
      discount = ?, 
      tax = ?, 
      payments = ?, 
      debt_amount = ?, 
      is_debt_paid = ?,
      remove_at = ?,
      purchase_order = ?
    WHERE id = ?
    ''',
      [
        updatedInvoice.storeId,
        updatedInvoice.invoiceNumber,
        updatedInvoice.invoiceName.value,
        updatedInvoice.createdAt.value?.toIso8601String(),
        updatedInvoice.sales.value,
        updatedInvoice.purchaseList.value.toJson(),
        updatedInvoice.discount.value,
        updatedInvoice.tax.value,
        updatedInvoice.payments.map((e) => e.toJson()).toList(),
        updatedInvoice.debtAmount.value,
        updatedInvoice.isDebtPaid.value ? 1 : 0,
        updatedInvoice.removeAt.value?.toIso8601String(),
        updatedInvoice.purchaseOrder.value ? 1 : 0,
        updatedInvoice.id,
      ],
    );

    await db.execute('DELETE FROM payments_sales WHERE invoice_number = ?',
        [updatedInvoice.invoiceNumber]);

    // for (var payment in updatedInvoice.payments) {
    //   print('update invoice payments ${payment.toJson()}');
    // }

    await insertListPayments(updatedInvoice.payments);
  }

  Future<void> updatePurchaseOrder(String id, bool purchaseOrder) async {
    await db.execute(
      '''
      UPDATE invoices_sales SET purchase_order = ? WHERE id = ?
    ''',
      [purchaseOrder, id],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      '''
      UPDATE invoices_sales SET remove_at = ? WHERE id = ?
    ''',
      [DateTime.now().toIso8601String(), id],
    );
  }
}
