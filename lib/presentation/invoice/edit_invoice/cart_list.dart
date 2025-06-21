import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/field_discount_widget/field_discount_widget.dart';
import '../../global_widget/field_quantity_widget/field_quantity_widget.dart';
import '../../global_widget/field_sell_widget/field_sell_widget.dart';
import 'edit_invoice_controller.dart';

class CartList extends StatelessWidget {
  const CartList({super.key, required this.cartItemList
      // this.isLockQty = false,
      });

  final Cart cartItemList;
  // final bool isLockQty;

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();
    // final bool isReturn = true;
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 4),
        itemCount: cartItemList.items.length,
        itemBuilder: (BuildContext context, int index) {
          return Obx(
            () {
              late CartItem productCart;

              if (cartItemList.items.isNotEmpty) {
                productCart = cartItemList.items[index];
              }
              RxDouble sellPrice =
                  switch (controller.editInvoice.priceType.value) {
                1 => productCart.product.sellPrice1,
                2 => productCart.product.sellPrice2 != null &&
                        productCart.product.sellPrice2 != 0.0.obs
                    ? productCart.product.sellPrice2!
                    : productCart.product.sellPrice1,
                3 => productCart.product.sellPrice3 != null &&
                        productCart.product.sellPrice3 != 0.0.obs
                    ? productCart.product.sellPrice3!
                    : productCart.product.sellPrice1,
                _ => productCart.product.sellPrice1,
              };

              final quantityTextC = TextEditingController();
              String displayQtyValue = productCart.quantity.value % 1 == 0
                  ? productCart.quantity.value.toInt().toString()
                  : productCart.quantity.value.toString().replaceAll('.', ',');
              quantityTextC.text = displayQtyValue;
              quantityTextC.selection = TextSelection.fromPosition(
                TextPosition(offset: quantityTextC.text.length),
              );

              final quantityReturnTextC = TextEditingController();
              String displayReturnQtyValue =
                  productCart.quantityReturn.value % 1 == 0
                      ? productCart.quantityReturn.value.toInt().toString()
                      : productCart.quantityReturn.value
                          .toString()
                          .replaceAll('.', ',');
              quantityReturnTextC.text = displayReturnQtyValue;
              quantityReturnTextC.selection = TextSelection.fromPosition(
                TextPosition(offset: quantityReturnTextC.text.length),
              );

              final discountTextC = TextEditingController();
              discountTextC.text = productCart.individualDiscount.value == 0
                  ? '-'
                  : currency.format(productCart.individualDiscount.value);
              discountTextC.selection = TextSelection.fromPosition(
                TextPosition(offset: discountTextC.text.length),
              );

              // bool emptyQty = ((productCart.quantity.value == 0 && !isReturn) ||
              //     (productCart.quantityReturn.value == 0 && isReturn));

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // if (isReturn)
                      Expanded(
                        // flex: 3,
                        child: Text(
                          '${index + 1}. ${productCart.product.productName}',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6))),
                        child: IconButton(
                          onPressed: () {
                            controller.removeItem(productCart.product);
                          },
                          icon: const Icon(
                            Symbols.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Rp${currency.format(productCart.product.getPrice(editInvoice.priceType.value).value)}',
                      // ),
                      Expanded(
                        // flex: 4,
                        child: Row(
                          children: [
                            Expanded(
                              child: SellTextfield(
                                title: 'Harga Jual',
                                asignNumber: sellPrice,
                                isDisable: false,
                                onChanged: (value) =>
                                    controller.sellPriceHandle(
                                  sellPrice,
                                  value,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        // flex: 7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: QuantityTextField(
                                item: productCart,
                                isReturn: false,
                                onChanged: (value) {
                                  controller.quantityHandle(productCart, value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          child: DiscountTextfield(
                            item: productCart,
                            onChanged: (value) {
                              controller.discountHandle(
                                productCart,
                                value,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (controller.editInvoice.priceType.value != 1 &&
                          sellPrice != productCart.product.sellPrice1)
                        Text(
                          'Rp${currency.format(productCart.product.sellPrice1.value)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall!
                              .copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      Expanded(
                        child: Text(
                            'Rp${currency.format(productCart.getBill(controller.editInvoice.priceType.value))}',
                            textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey[400]),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
