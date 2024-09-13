import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/field_cost_widget/field_cost_widget.dart';
import '../../global_widget/field_discount_widget/field_discount_widget.dart';
import '../../global_widget/field_quantity_widget/field_quantity_widget.dart';
import '../../global_widget/field_sell_widget/field_sell_widget.dart';
import 'buy_product_controller.dart';

class CartSalesWidget extends StatelessWidget {
  const CartSalesWidget({
    super.key,
    required this.item,
    required this.index,
  });

  final CartItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    late BuyProductController controller = Get.find();

    final discountTextC = TextEditingController();
    discountTextC.text = currency.format(item.individualDiscount.value);
    discountTextC.selection = TextSelection.fromPosition(
      TextPosition(offset: discountTextC.text.length),
    );

    final costPriceTextC = TextEditingController();
    costPriceTextC.text = currency.format(item.individualDiscount.value);
    costPriceTextC.selection = TextSelection.fromPosition(
      TextPosition(offset: costPriceTextC.text.length),
    );
    return Obx(
      () {
        // final qtyTextC = TextEditingController();
        // String displayValue = item.quantity.value % 1 == 0
        //     ? item.quantity.value.toInt().toString()
        //     : item.quantity.value.toString().replaceAll('.', ',');
        // qtyTextC.text = displayValue;
        // qtyTextC.selection = TextSelection.fromPosition(
        //   TextPosition(offset: qtyTextC.text.length),
        // );

        // final costPriceTextC = TextEditingController();
        // costPriceTextC.text = currency.format(item.product.costPrice.value);
        // costPriceTextC.selection = TextSelection.fromPosition(
        //   TextPosition(offset: costPriceTextC.text.length),
        // );

        // int getPrice = item.getPrice(controller.priceType.value);
        // int sellPrice = getPrice != 0 ? getPrice : item.product.sellPrice1;
        return Container(
          color: index.isEven ? Colors.grey[100] : Colors.white,
          child: ListTile(
            // tileColor: index.isEven ? Colors.grey[100] : Colors.white,
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            title: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    child: Text(
                      '${index + 1}. ${item.product.productName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: IconButton(
                    onPressed: () {
                      // if (isEdit) {
                      //   invoice!.purchaseList.value
                      //       .removeItem(item.product.id!);
                      //   invoice!.updateIsDebtPaid();
                      // } else {
                      //   controller.removeFromCart(item);
                      // }
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
            subtitle: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: CostTextfield(
                                item: item,
                                onChanged: (value) {},
                                // onChanged: (value) => controller.costHandle(
                                //   item,
                                //   value,
                                // ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expanded(
                    //   flex: 5,
                    //   child: SizedBox(
                    //     child: Text(
                    //       'Rp${controller.currency.format(item.product.costPrice)}',
                    //       style: context.textTheme.bodyMedium,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: QuantityTextField(
                                item: item,
                                onChanged: (value) {},
                                // onChanged: (value) => controller.quantityHandle(
                                //   item,
                                //   value,
                                // ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: DiscountTextfield(
                                item: item,
                                onChanged: (value) => controller.discountHandle(
                                    item.product.id!, value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp${currency.format(item.product.costPrice * item.quantity.value - item.individualDiscount.value)}',
                              style: context.textTheme.titleMedium,
                            ),
                            if (item.individualDiscount.value > 0)
                              Text(
                                'Rp${currency.format(item.product.costPrice * item.quantity.value)}',
                                style: context.textTheme.bodySmall!.copyWith(
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.lineThrough),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: SellTextfield(
                                title: 'Harga Jual 1',
                                asignNumber: item.product.sellPrice1,
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: SellTextfield(
                                title: 'Harga Jual 2',
                                asignNumber: item.product.sellPrice2 ?? 0.0.obs,
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: SellTextfield(
                                title: 'Harga Jual 3',
                                asignNumber: item.product.sellPrice3 ?? 0.0.obs,
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(flex: 6, child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
