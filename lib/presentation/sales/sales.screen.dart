import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/sales.controller.dart';
import 'sales_list.dart';
import 'selected_sales_invoice.dart';

class SalesScreen extends GetView<SalesController> {
  const SalesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MenuWidget(title: 'Sales'),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Card(
                      child: SalesList(
                          onClick: (sales) =>
                              controller.selectedSalesHandle(sales))),
                ),
                const Expanded(
                  flex: 5,
                  child: Card(child: SelectedSalesInvoice()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
