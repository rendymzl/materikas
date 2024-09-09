import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/invoice.controller.dart';
import 'invoice_list.dart';

class InvoiceScreen extends GetView<InvoiceController> {
  const InvoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MenuWidget(title: 'Invoice'),
          Expanded(
            child: Card(
              child: Expanded(child: const InvoiceList()),
            ),
          ),
        ],
      ),
    );
  }
}
