import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../../infrastructure/utils/display_format.dart';
import '../../field_discount_widget/field_discount_widget.dart';
import '../../field_quantity_widget/field_quantity_widget.dart';
import '../../field_sell_widget/field_sell_widget.dart';
import '../../../product/detail_product/image_product.dart';
import '../../../home/controllers/home.controller.dart';

class VerticalCartTransaction extends StatelessWidget {
  const VerticalCartTransaction({
    super.key,
    required this.item,
    required this.priceType,
  });

  final CartItem item;
  final RxInt priceType;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Obx(() {
      final sellPrice = _calculateSellPrice(item, priceType.value);
      final totalPrice =
          sellPrice * item.quantity.value - item.individualDiscount.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Divider(color: Colors.grey),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(context),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.product.productName,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5))),
                                  child: IconButton(
                                    onPressed: () =>
                                        controller.removeFromCart(item),
                                    icon: const Icon(
                                      Symbols.close,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      SellTextfield(
                                        title: 'Harga Jual',
                                        asignNumber: sellPrice,
                                        onChanged: (value) => controller
                                            .sellPriceHandle(sellPrice, value),
                                      ),
                                      if (priceType.value != 1 &&
                                          sellPrice != item.product.sellPrice1)
                                        Text(
                                          'Rp${currency.format(item.product.sellPrice1.value)}',
                                          style: context.textTheme.bodySmall!
                                              .copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DiscountTextfield(
                                    item: item,
                                    onChanged: (value) =>
                                        controller.discountHandle(
                                            item.product.id!, value),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: QuantityTextField(
                          item: item,
                          onChanged: (value) =>
                              controller.quantityHandle(item, value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildTotalPrice(context, totalPrice),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductImage(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.product.imageUrl != null
              ? ImageProductWidget(product: item.product)
              : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      item.product.productName.isNotEmpty
                          ? item.product.productName[0].toUpperCase()
                          : '',
                      style: context.textTheme.headlineSmall!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTotalPrice(BuildContext context, double totalPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Rp ${currency.format(totalPrice)}',
          style: context.textTheme.titleMedium,
        ),
        if (item.individualDiscount.value > 0)
          Text(
            'Rp ${currency.format(item.quantity.value * _calculateSellPrice(item, priceType.value).value)}',
            style: context.textTheme.bodySmall!.copyWith(
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.lineThrough),
          ),
      ],
    );
  }

  RxDouble _calculateSellPrice(CartItem item, int priceType) {
    switch (priceType) {
      case 1:
        return item.product.sellPrice1;
      case 2:
        return item.product.sellPrice2 != null &&
                item.product.sellPrice2 != 0.0.obs
            ? item.product.sellPrice2!
            : item.product.sellPrice1;
      case 3:
        return item.product.sellPrice3 != null &&
                item.product.sellPrice3 != 0.0.obs
            ? item.product.sellPrice3!
            : item.product.sellPrice1;
      default:
        return item.product.sellPrice1;
    }
  }
}
