import 'dart:isolate';

import 'package:intl/intl.dart';

import '../../models/invoice_model/invoice_model.dart';
import '../database/powersync.dart';

// void isolatePaidStream(SendPort sendPort) async {
//   print('listenPaid: Start isolatePaidStream');
//   final invoicePaidStream = db.watch('''
//   SELECT
//     invoices.id,
//     invoices.store_id,
//     invoices.invoice_id,
//     invoices.created_at,
//     invoices.account,
//     invoices.customer,
//     invoices.purchase_list,
//     invoices.return_list,
//     invoices.after_return_list,
//     invoices.price_type,
//     invoices.discount,
//     invoices.tax,
//     invoices.return_fee,
//     invoices.remove_product,
//     invoices.debt_amount,
//     invoices.app_bill_amount,
//     invoices.is_debt_paid,
//     invoices.is_app_bill_paid,
//     invoices.other_costs,
//     invoices.init_at,
//     invoices.remove_at,
//       '[' || GROUP_CONCAT(
//       '{ "id": "' || payments.id || '"' ||
//       ', "invoice_id": "' || payments.invoice_id || '"' ||
//       ', "store_id": "' || payments.store_id || '"' ||
//       ', "invoice_created_at": "' || payments.invoice_created_at || '"' ||
//       ', "date": "' || payments.date || '"' ||
//       ', "method": "' || payments.method || '"' ||
//       ', "final_amount_paid": ' || payments.final_amount_paid ||
//       ', "remain": ' || payments.remain ||
//       ', "amount_paid": ' || payments.amount_paid ||
//       '}', ', '
//     ) || ']' AS payments
//   FROM
//     invoices
//   LEFT JOIN
//     payments ON invoices.invoice_id = payments.invoice_id
//   WHERE
//     invoices.created_at BETWEEN ? AND ?
//     AND invoices.remove_at IS NULL
//     AND invoices.is_debt_paid = 1
//   GROUP BY
//     invoices.invoice_id
//   ORDER BY
//     invoices.created_at DESC;
//     ''', parameters: [
//     DateFormat('yyyy-MM-dd').format(DateTime.now()),
//     DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1))),
//   ]).map((data) => data.toList());


//   invoicePaidStream.listen((datas) async {
//     var dataModel = datas.map((e) => InvoiceModel.fromJson(e)).toList();
//     sendPort.send(dataModel);

//   });
// }
