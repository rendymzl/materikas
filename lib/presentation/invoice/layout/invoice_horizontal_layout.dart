import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invoice.controller.dart';
import '../widget/invoice_header.dart';
import '../widget/invoice_list_horizontal.dart';

class InvoiceHorizontalLayout extends StatelessWidget {
  final InvoiceController controller;

  const InvoiceHorizontalLayout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InvoiceHeader(controller: controller),
              )),
        ),
        // SizedBox(height: 2),
        // buildInvoiceStatusSummary(),
        Expanded(
          flex: 10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                    elevation: 0, child: InvoiceListHorizontal(isDebt: false)),
              ),
              // const SizedBox(width: 4),
              Expanded(
                  child: Card(
                      elevation: 0,
                      child: InvoiceListHorizontal(isDebt: true))),
              const SizedBox(width: 8),
            ],
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget buildInvoiceStatusSummary() {
    return Row(
      children: [
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green[100],
              child: Text(
                'INVOICE LUNAS',
                textAlign: TextAlign.center,
                style: Get.context!.textTheme.titleLarge!.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Text(
                'INVOICE BELUM LUNAS',
                textAlign: TextAlign.center,
                style: Get.context!.textTheme.titleLarge!.copyWith(
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
      ],
    );
  }
}
