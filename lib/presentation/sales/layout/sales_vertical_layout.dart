import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../controllers/sales.controller.dart';
import '../sales_list_widget.dart';

class SalesVerticalLayout extends StatelessWidget {
  final SalesController controller;

  const SalesVerticalLayout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SalesListWidget(
      onSalesTap: (sales) {
        controller.selectedSalesHandle(sales);
        Get.toNamed(Routes.INVOICE_SALES_LIST);
      },
    );
  }
}
