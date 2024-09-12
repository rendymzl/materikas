import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/field_discount_widget/field_discount_widget.dart';
import '../../global_widget/field_quantity_widget/field_quantity_widget.dart';
import 'edit_invoice_controller.dart';

class SingleCartList extends StatelessWidget {
  const SingleCartList({
    super.key,
    required this.editInvoice,
    required this.cartItemList,
    this.isReturn = false,
  });

  final InvoiceModel editInvoice;
  final Cart cartItemList;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
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

              bool emptyQty = ((productCart.quantity.value == 0 && !isReturn) ||
                  (productCart.quantityReturn.value == 0 && isReturn));

              return Column(
                children: [
                  ListTile(
                    tileColor: Colors.grey[200],
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isReturn)
                          Text(
                            '${index + 1}. ${productCart.product.productName}',
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        if (isReturn)
                          if (productCart.quantityReturn.value > 0)
                            ReturnButton(
                                productCart: productCart, isReturn: true),
                        if (!isReturn)
                          if (productCart.quantity.value > 0)
                            ReturnButton(productCart: productCart),
                      ],
                    ),
                    trailing: isReturn
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
                                controller.remove(productCart, cartItemList);
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
                    enabled: !emptyQty,
                    tileColor: emptyQty
                        ? isReturn
                            ? Colors.red[50]!.withOpacity(0.5)
                            : Colors.green[50]!.withOpacity(0.5)
                        : isReturn
                            ? Colors.red[50]
                            : Colors.green[50],
                    title: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rp${currency.format(productCart.product.getPrice(editInvoice.priceType.value).value)}',
                              ),
                              SizedBox(
                                width: 100,
                                child: QuantityTextField(
                                  item: productCart,
                                  isReturn: isReturn,
                                  onChanged: (value) {
                                    controller.quantityHandle(
                                      productCart,
                                      value,
                                      isReturn,
                                    );
                                  },
                                ),
                              ),
                              if (!isReturn)
                                SizedBox(
                                  width: 130,
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isReturn &&
                                      productCart.individualDiscount.value > 0)
                                    Text(
                                      'Rp${currency.format(productCart.getSubBill(editInvoice.priceType.value))}',
                                      style: context.textTheme.bodySmall!
                                          .copyWith(
                                              fontStyle: FontStyle.italic,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                    ),
                                  const SizedBox(width: 12),
                                  isReturn
                                      ? Text(
                                          'Rp${currency.format(productCart.getReturn(editInvoice.priceType.value))}')
                                      : Text(
                                          'Rp${currency.format(productCart.getBill(editInvoice.priceType.value))}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ReturnButton extends StatelessWidget {
  const ReturnButton({
    super.key,
    required this.productCart,
    this.isReturn = false,
  });

  final CartItem productCart;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();
    return InkWell(
      onTap: () => controller.quantityMoveHandle(productCart, isReturn),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (!isReturn)
              const Icon(
                Symbols.arrow_left,
                color: Colors.white,
              ),
            Text(
              isReturn ? 'Batal Return' : 'Return',
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (isReturn)
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
