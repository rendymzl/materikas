import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import 'row_table.dart';

class ProductTableSales extends StatelessWidget {
  const ProductTableSales({super.key, required this.invoice});

  final InvoiceSalesModel invoice;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.grey[200],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => Column(
            children: [
              // Divider(color: Colors.grey[200]),
              const RowTableSales(isHeader: true),
              Divider(color: Colors.grey[200]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.green[50],
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: invoice.purchaseList.value.items.length,
                      itemBuilder: (context, index) {
                        final purchaseItem =
                            invoice.purchaseList.value.items[index];

                        return RowTableSales(
                          purchaseItem: purchaseItem,
                          invoice: invoice,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
