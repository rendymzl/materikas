import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class RowTableSales extends StatelessWidget {
  const RowTableSales({
    this.invoice,
    this.purchaseItem,
    this.isHeader = false,
    super.key,
  });
  final InvoiceSalesModel? invoice;
  final CartItem? purchaseItem;
  final bool isHeader;
  @override
  Widget build(BuildContext context) {
    String productName = '-';
    String cost = '-';
    String subCost = '-';
    String totalCost = '-';
    String discount = '-';
    late String quantityPurchase;
    if (purchaseItem != null && invoice != null) {
      productName = purchaseItem!.product.productName;

      cost = 'Rp${currency.format(purchaseItem!.product.costPrice.value)}';
      subCost = 'Rp${currency.format(purchaseItem!.subCost)}';
      totalCost =
          'Rp${currency.format(purchaseItem!.subCost - purchaseItem!.individualDiscount.value)}';
      if (purchaseItem!.individualDiscount.value != 0) {
        discount =
            'Rp-${currency.format(purchaseItem!.individualDiscount.value)}';
      }
      quantityPurchase =
          '${purchaseItem!.quantityTotalDisplay} ${purchaseItem!.product.unit}';
    }

    return ListTile(
      dense: true,
      title: Row(
        children: [
          Expanded(
              flex: 6,
              child: Row(
                children: [
                  Text(
                    isHeader ? 'NAMA BARANG' : productName,
                    style: isHeader
                        ? Theme.of(Get.context!).textTheme.titleLarge
                        : null,
                  ),
                  const SizedBox(width: 16),
                ],
              )),
          Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      '',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: isHeader ? 4 : 1,
                    child: Text(
                      isHeader ? 'HARGA BARANG' : cost,
                      style: isHeader
                          ? Theme.of(Get.context!).textTheme.titleLarge
                          : null,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              )),
          Expanded(
              flex: 2,
              child: Text(
                isHeader ? 'JUMLAH' : quantityPurchase,
                style: isHeader
                    ? Theme.of(Get.context!).textTheme.titleLarge
                    : null,
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 3,
              child: Text(
                isHeader ? 'DISKON' : discount,
                style: isHeader
                    ? Theme.of(Get.context!).textTheme.titleLarge
                    : null,
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (discount != '-')
                    Text(
                      subCost,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.lineThrough,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    isHeader ? 'TOTAL HARGA' : totalCost,
                    style: isHeader
                        ? Theme.of(Get.context!).textTheme.titleLarge
                        : null,
                    textAlign: TextAlign.end,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
