import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
// import '../../../infrastructure/models/invoice_model/cart_model.dart';
// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/utils/display_format.dart';
// import '../../global_widget/field_discount_widget/field_discount_widget.dart';
import '../../global_widget/field_quantity_widget/field_quantity_widget.dart';
import '../../global_widget/field_sell_widget/field_sell_widget.dart';
import 'edit_invoice_controller.dart';

class ReturnCartList extends StatelessWidget {
  const ReturnCartList({
    super.key,
    // required this.editInvoice,
    // required this.cartItemList,
    this.isPureReturn = false,
  });

  // final InvoiceModel editInvoice;
  // final Cart cartItemList;
  final bool isPureReturn;

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();
    final Cart cartItemList = isPureReturn
        ? controller.editInvoice.purchaseList.value
        : controller.editInvoice.returnList.value!;
    // final bool isReturn = true;
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.grey),
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

              return Column(
                children: [
                  // Divider(color: Colors.grey),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${index + 1}. ${productCart.product.productName}',
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        if (isPureReturn)
                          Button(
                              productCart: productCart,
                              returnButton: true,
                              isDisable: productCart.quantity.value <= 0),
                        SizedBox(width: 12),
                        if (isPureReturn)
                          Button(
                              productCart: productCart,
                              isDisable: productCart.quantityReturn.value <= 0),
                      ],
                    ),
                    trailing: isPureReturn
                        ? null
                        : Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            child: IconButton(
                              onPressed: () {
                                controller.removeNewReturn(productCart.product);
                              },
                              icon: const Icon(
                                Symbols.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  ListTile(
                    title: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SellTextfield(
                                          title: 'Harga Jual',
                                          asignNumber: sellPrice,
                                          isDisable: true,
                                          onChanged: (value) =>
                                              controller.sellPriceHandle(
                                            sellPrice,
                                            value,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (controller.editInvoice.priceType.value !=
                                          1 &&
                                      sellPrice !=
                                          productCart.product.sellPrice1)
                                    Text(
                                      'Rp${currency.format(productCart.product.sellPrice1.value)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodySmall!
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.lineThrough),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: QuantityTextField(
                                          title: 'Jumlah di Return',
                                          item: productCart,
                                          isReturn: true,
                                          onChanged: (value) {
                                            isPureReturn
                                                ? controller
                                                    .quantityReturnHandle(
                                                        productCart, value)
                                                : controller
                                                    .quantityNewReturnHandle(
                                                        productCart, value);
                                            // }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isPureReturn)
                                    Column(
                                      children: [
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text('Pembelian: '),
                                            Text(
                                                number.format(
                                                    productCart.quantity.value),
                                                textAlign: TextAlign.right),
                                          ],
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              // flex: 3,
                              child: Text(
                                  'Rp${currency.format(productCart.getReturn(controller.editInvoice.priceType.value))}',
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Divider(color: Colors.grey[400]),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.productCart,
    this.returnButton = false,
    this.isDisable = false,
  });

  final CartItem productCart;
  final bool returnButton;
  final bool isDisable;

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();
    return InkWell(
      onTap: isDisable
          ? null
          : () {
              print('returnButton $returnButton');
              return returnButton
                  ? controller.addToReturnCart(productCart.product)
                  : controller.substractFromReturnCart(productCart.product);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color:
              isDisable ? Colors.grey : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (returnButton)
              const Icon(
                Symbols.arrow_left,
                color: Colors.white,
              ),
            Text(
              !returnButton ? '' : 'Return',
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (!returnButton)
              const Icon(
                Symbols.arrow_right,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
