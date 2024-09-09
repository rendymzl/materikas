import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/field_discount_widget/field_discount_widget.dart';
import '../../global_widget/field_quantity_widget/field_quantity_widget.dart';
import '../controllers/home.controller.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({
    super.key,
    required this.item,
    required this.index,
  });

  final CartItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Obx(
      () {
        double getPrice = item.getPrice(controller.priceType.value);
        double sellPrice =
            getPrice != 0 ? getPrice : item.product.sellPrice1.value;
        return Container(
          color: index.isEven ? Colors.grey[100] : Colors.white,
          child: ListTile(
            title: Row(
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
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
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
            subtitle: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp${currency.format(sellPrice)}',
                          style: context.textTheme.bodyMedium,
                        ),
                        if (controller.priceType.value != 1 &&
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
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    child: Row(
                      children: [
                        Expanded(
                          child: QuantityTextField(
                            item: item,
                            onChanged: (value) => controller.quantityHandle(
                              item,
                              value,
                            ),
                          ),
                        ),
                      ],
                    ),
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
          ),
        );
      },
    );
  }
}
