import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../infrastructure/models/invoice_sales_model.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/popup_page_widget.dart';
import '../invoice/detail_invoice/properties_row.dart';

void detailSalesPaymentMobile(RxList<InvoiceSalesModel> invoice) {
  showPopupPageWidget(
    title: 'Detail Pembayaran Sales',
    height: MediaQuery.of(Get.context!).size.height * 0.85,
    width: MediaQuery.of(Get.context!).size.width * 0.9, // Lebar disesuaikan
    content: Expanded(
      child: ListView.builder(
        itemCount: invoice.length,
        itemBuilder: (context, index) {
          final inv = invoice[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Invoice
                  Text(
                    inv.invoiceName.value!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  // Nama Sales
                  Text(
                    'Sales: ${inv.sales.value?.name ?? ''}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  // Daftar Pembayaran
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inv.payments.length,
                    itemBuilder: (context, paymentIndex) {
                      final payment = inv.payments[paymentIndex];
                      return ListTile(
                        leading: Text('${paymentIndex + 1}.'),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${payment.method!} (${DateFormat('dd MMM y', 'id').format(payment.date!)})',
                              style: TextStyle(
                                color: payment.method == 'cash'
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                            Text(
                              'Rp${currency.format(payment.amountPaid)}',
                              style: TextStyle(
                                color: payment.method == 'cash'
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
