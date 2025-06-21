import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../../infrastructure/utils/display_format.dart';
import '../../field_discount_widget/field_discount_widget.dart';
import '../../field_quantity_widget/field_quantity_widget.dart';
import '../../field_sell_widget/field_sell_widget.dart';
import '../../../home/controllers/home.controller.dart';

class HorizontalCartTransaction extends StatelessWidget {
  const HorizontalCartTransaction({
    super.key,
    required this.item,
    required this.index,
    required this.priceType,
  });

  final CartItem item;
  final int index;
  final RxInt priceType;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Obx(
      () {
        RxDouble sellPrice = switch (priceType.value) {
          1 => item.product.sellPrice1,
          2 => item.product.sellPrice2 != null &&
                  item.product.sellPrice2 != 0.0.obs
              ? item.product.sellPrice2!
              : item.product.sellPrice1,
          3 => item.product.sellPrice3 != null &&
                  item.product.sellPrice3 != 0.0.obs
              ? item.product.sellPrice3!
              : item.product.sellPrice1,
          _ => item.product.sellPrice1,
        };
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.1),
            //     spreadRadius: 1,
            //     blurRadius: 3,
            //     offset: const Offset(0, 1),
            //   ),
            // ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${index + 1}. ${item.product.productName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      child: IconButton(
                        onPressed: () => controller.removeFromCart(item),
                        icon: const Icon(
                          Symbols.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SellTextfield(
                                    title: 'Harga Jual',
                                    asignNumber: sellPrice,
                                    onChanged: (value) =>
                                        controller.sellPriceHandle(
                                      sellPrice,
                                      value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (priceType.value != 1 &&
                                sellPrice != item.product.sellPrice1)
                              Text(
                                'Rp${currency.format(item.product.sellPrice1.value)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall!.copyWith(
                                    decoration: TextDecoration.lineThrough),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: QuantityTextField(
                        item: item,
                        onChanged: (value) =>
                            controller.quantityHandle(item, value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
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
                              'Rp ${currency.format(sellPrice * item.quantity.value - item.individualDiscount.value)}',
                              style: context.textTheme.titleMedium,
                            ),
                            if (item.individualDiscount.value > 0)
                              Text(
                                'Rp ${currency.format(sellPrice * item.quantity.value)}',
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
              ],
            ),
          ),
        );
      },
    );
  }
}
