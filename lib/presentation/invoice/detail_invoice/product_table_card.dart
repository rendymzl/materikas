import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import 'row_table.dart';

class ProductTableCard extends StatelessWidget {
  const ProductTableCard({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // Divider(color: Colors.grey[200]),
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const RowTable(isHeader: true)),
          Divider(color: Colors.grey[200]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (invoice.isReturn)
              //   const Text(
              //     'Pesanan:',
              //     style: TextStyle(
              //         color: Colors.grey, fontStyle: FontStyle.italic),
              //   ),
              Container(
                color: Colors.green[50],
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: invoice.purchaseList.value.items.length,
                  itemBuilder: (context, index) {
                    final purchaseItem =
                        invoice.purchaseList.value.items[index];

                    print('purchase item ${purchaseItem.toJson()}');
                    return RowTable(
                      purchaseItem: purchaseItem,
                      invoice: invoice,
                    );
                  },
                ),
              ),
            ],
          ),
          if (invoice.isReturn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pesanan di Return:',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                Container(
                  color: Colors.red[50],
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: invoice.purchaseList.value.items.length,
                    itemBuilder: (context, index) {
                      final purchaseItem =
                          invoice.purchaseList.value.items[index];

                      return RowTable(
                        purchaseItem: purchaseItem,
                        invoice: invoice,
                        isReturn: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          if (invoice.returnList.value != null)
            if (invoice.returnList.value!.items.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambahan Return:',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  Container(
                    color: Colors.red[50],
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: invoice.returnList.value!.items.length,
                      itemBuilder: (context, index) {
                        final purchaseItem =
                            invoice.returnList.value!.items[index];

                        return RowTable(
                          purchaseItem: purchaseItem,
                          invoice: invoice,
                          isReturn: true,
                          isAdditionalReturn: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
          if (invoice.purchaseList.value.bundleDiscount.value > 0)
            RowTable(
                invoice: invoice,
                isAdditionalDiscount:
                    invoice.purchaseList.value.bundleDiscount.value > 0),
          Divider(color: Colors.grey[200]),
        ],
      ),
    );
  }
}
