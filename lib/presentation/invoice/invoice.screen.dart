import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/invoice.controller.dart';
import 'invoice_list.dart';

class InvoiceScreen extends GetView<InvoiceController> {
  const InvoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //       onPressed: () => controller.fixPayment(),
      //       icon: const Icon(Symbols.body_system)),
      // ),
      body: Column(
        children: [
          MenuWidget(title: 'Invoice'),
          Expanded(
            child: Card(
              child: InvoiceList(),
            ),
          ),
        ],
      ),
    );
  }
}
