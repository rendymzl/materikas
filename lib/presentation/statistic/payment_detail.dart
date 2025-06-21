import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/popup_page_widget.dart';
import '../invoice/detail_invoice/properties_row.dart';

void detailPayment(RxList<InvoiceModel> invoice) {
  print('lenght debug ${invoice.length}');
  showPopupPageWidget(
    title: 'Detail Pembayaran',
    height: MediaQuery.of(Get.context!).size.height * (0.9),
    width: MediaQuery.of(Get.context!).size.width * (0.5),
    content: ListView.builder(
      shrinkWrap: true,
      itemCount: invoice.length,
      itemBuilder: (context, index) {
        final inv = invoice[index];
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(inv.invoiceId!)),
              Expanded(child: Text(inv.customer.value?.name ?? '')),
              Expanded(
                flex: 3,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: inv.payments.length,
                  itemBuilder: (context, index) {
                    return PropertiesRow(
                      primary: true,
                      payment: true,
                      paymentMethod: inv.payments[index].method!,
                      title:
                          '${index + 1}. ${inv.payments[index].method!} (${DateFormat('dd MMM y', 'id').format(inv.payments[index].date!)})',
                      value:
                          'Rp${currency.format(inv.payments[index].amountPaid)}',
                    );
                  },
                ),
              ),
            ],
          ),
          // subtitle: ListView.builder(
          //   shrinkWrap: true,
          //   itemCount: inv.payments.length,
          //   itemBuilder: (context, index) {
          //     return PropertiesRow(
          //       primary: true,
          //       payment: true,
          //       paymentMethod: inv.payments[index].method!,
          //       title: '${index + 1}. ${inv.payments[index].method!} (${DateFormat('dd MMM y', 'id').format(inv.payments[index].date!)})',
          //       value: 'Rp${currency.format(inv.payments[index].amountPaid)}',
          //     );
          //   },
          // ),
        );
      },
    ),
  );
}
