import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/field_cost_widget/field_cost_widget.dart';
import '../../global_widget/field_discount_widget/field_discount_widget.dart';
import '../../global_widget/field_quantity_widget/field_quantity_widget.dart';
import '../../global_widget/field_sell_widget/field_sell_widget.dart';
import 'buy_product_controller.dart';

class CartSalesMobile extends StatelessWidget {
  const CartSalesMobile({
    super.key,
    required this.item,
    required this.index,
    required this.cart,
    this.isEdit = false,
    // this.po = false,
  });

  final CartItem item;
  final int index;
  final Cart cart;
  final bool isEdit;
  // final bool po;

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
        return Container(
          // color: index.isEven ? Colors.grey[100] : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${index + 1}. ${item.product.productName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: IconButton(
                      onPressed: () => isEdit
                          ? controller.removeFromEditCart(item.product, cart)
                          : controller.removeFromCart(item),
                      icon: const Icon(
                        Symbols.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {},
                  //   // onPressed: () =>
                  //   //     controller.removeFromCart(item, cart, po: po),
                  //   icon: const Icon(
                  //     Symbols.close,
                  //     size: 20,
                  //     color: Colors.red,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CostTextfield(
                      item: item,
                      onChanged: (value) => controller.costHandle(item, value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // if (!po)
                  Expanded(
                    child: DiscountTextfield(
                      item: item,
                      onChanged: (value) => isEdit
                          ? controller.discountEditHandle(
                              item.product.id!, value, cart)
                          : controller.discountHandle(item.product.id!, value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // if (!po)
              Row(
                children: [
                  Expanded(
                    child: SellTextfield(
                      title: 'Harga Jual 1',
                      asignNumber: item.product.sellPrice1,
                      onChanged: (value) =>
                          controller.sellHandle(item.product.sellPrice1, value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SellTextfield(
                      title: 'Harga Jual 2',
                      asignNumber: item.product.sellPrice2 ?? 0.0.obs,
                      onChanged: (value) => controller.sellHandle(
                          item.product.sellPrice2 ?? 0.0.obs, value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SellTextfield(
                      title: 'Harga Jual 3',
                      asignNumber: item.product.sellPrice3 ?? 0.0.obs,
                      onChanged: (value) => controller.sellHandle(
                          item.product.sellPrice3 ?? 0.0.obs, value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: QuantityTextField(
                        item: item,
                        onChanged: (value) => isEdit
                            ? controller.quantityEditHandle(item, value, cart)
                            : controller.quantityHandle(item, value),
                        // controller.quantityHandle(item, value, po: po),
                        // onChanged: (value) =>
                        //     controller.quantityHandle(item, value, po: po),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
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
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
