import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class RowTable extends StatelessWidget {
  const RowTable({
    this.invoice,
    this.purchaseItem,
    this.isHeader = false,
    this.isReturn = false,
    this.isAdditionalReturn = false,
    this.isAdditionalDiscount = false,
    super.key,
  });
  final InvoiceModel? invoice;
  final CartItem? purchaseItem;
  final bool isHeader;
  final bool isReturn;
  final bool isAdditionalReturn;
  final bool isAdditionalDiscount;
  @override
  Widget build(BuildContext context) {
    String productName = '-';
    String price = '-';
    String discount = '-';
    String totalPurchase = '-';
    String quantityDisplay = '';
    String quantityReturnDisplay = '';
    String quantityReturn = '';
    late String subTotalReturn;
    late String quantityPurchase;
    late String subTotalPurchase;
    if (purchaseItem != null && invoice != null) {
      productName = purchaseItem!.product.productName;

      price =
          'Rp${currency.format(purchaseItem!.product.getPrice(invoice!.priceType.value).value)}';
      if (purchaseItem!.individualDiscount.value != 0) {
        discount =
            'Rp-${currency.format(purchaseItem!.individualDiscount.value)}';
      }
      totalPurchase =
          'Rp${currency.format(purchaseItem!.getSubBill(invoice!.priceType.value))}';

      quantityDisplay = purchaseItem!.quantityDisplay;
      quantityReturnDisplay = purchaseItem!.quantityReturnDisplay;

      quantityReturn =
          '-${purchaseItem!.quantityReturnDisplay} ${purchaseItem!.product.unit}';
      subTotalReturn =
          'Rp-${currency.format(purchaseItem!.getReturn(invoice!.priceType.value))}';
      quantityPurchase =
          '${number.format(purchaseItem!.quantity.value)} ${purchaseItem!.product.unit}';
      subTotalPurchase =
          'Rp${currency.format(purchaseItem!.getBill(invoice!.priceType.value))}';
    }
    print('quantity ${quantityDisplay}');
    return (!isAdditionalDiscount)
        ? (isReturn && (quantityReturnDisplay == '0') ||
                (!isReturn && (quantityDisplay == '0')))
            ? const SizedBox()
            : ListTile(
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
                                isHeader ? 'HARGA BARANG' : price,
                                style: isHeader
                                    ? Theme.of(Get.context!)
                                        .textTheme
                                        .titleLarge
                                    : null,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 2,
                        child: Text(
                          isHeader
                              ? 'JUMLAH'
                              : isReturn
                                  ? quantityReturn
                                  : quantityPurchase,
                          style: isHeader
                              ? Theme.of(Get.context!).textTheme.titleLarge
                              : isReturn
                                  ? Theme.of(Get.context!).textTheme.bodySmall
                                  : null,
                          textAlign: TextAlign.right,
                        )),
                    Expanded(
                        flex: 3,
                        child: Text(
                          isHeader
                              ? 'DISKON'
                              : isReturn || isAdditionalReturn
                                  ? ''
                                  : discount,
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
                            if (discount != '-' && !isReturn)
                              Text(
                                totalPurchase,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              isHeader
                                  ? 'TOTAL HARGA'
                                  : isReturn
                                      ? subTotalReturn
                                      : subTotalPurchase,
                              style: isHeader
                                  ? Theme.of(Get.context!).textTheme.titleLarge
                                  : isReturn
                                      ? const TextStyle(color: Colors.red)
                                      : null,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        )),
                  ],
                ),
              )
        : ListTile(
            dense: true,
            title: Row(
              children: [
                Expanded(
                    flex: 16,
                    child: Text(
                      'Diskon Tambahan:    Rp-${currency.format(invoice!.purchaseList.value.bundleDiscount.value)}',
                      textAlign: TextAlign.right,
                    )),
                Expanded(flex: 5, child: Text('')),
              ],
            ),
            // trailing: IconButton(
            //   onPressed: () {},
            //   icon: Icon(Symbols.edit_square),
            // ),
          );
  }
}
