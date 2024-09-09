import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/date_picker_widget/date_picker_widget.dart';
import '../controllers/home.controller.dart';
import 'calculate_price.dart';
import 'cartlist.dart';

class SelectedProduct extends StatelessWidget {
  const SelectedProduct({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          PriceTypeWidget(),
          Divider(color: Colors.grey[100]),
          Obx(() {
            return controller.cart.value.items.isNotEmpty
                ? Expanded(
                    flex: 10,
                    child: CartListWidget(),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Barang yang Anda klik akan ditampilkan di sini.',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  );
          }),
          Obx(() {
            return controller.cart.value.items.isNotEmpty
                ? SizedBox(
                    child: Column(
                      children: [
                        Divider(color: Colors.grey[200]),
                        Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: CalculatePrice(),
                        ),
                      ],
                    ),
                  ) //* 2.0 CalculatePrice
                : const SizedBox();
          })
        ],
      ),
    );
  }
}

class PriceTypeWidget extends StatelessWidget {
  const PriceTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(
                () => InkWell(
                  onTap: () => controller.priceTypeHandleCheckBox(2),
                  child: SizedBox(
                    child: Row(
                      children: [
                        Checkbox(
                          value: controller.priceType.value == 2,
                          onChanged: (value) =>
                              controller.priceTypeHandleCheckBox(2),
                        ),
                        Text(
                          'Harga masuk gang',
                          style: controller.priceType.value == 2
                              ? context.textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.primary)
                              : context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Obx(
                () => InkWell(
                  onTap: () => controller.priceTypeHandleCheckBox(3),
                  child: SizedBox(
                    child: Row(
                      children: [
                        Checkbox(
                          value: controller.priceType.value == 3,
                          onChanged: (value) =>
                              controller.priceTypeHandleCheckBox(3),
                        ),
                        Text(
                          'Harga material',
                          style: controller.priceType.value == 3
                              ? context.textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.primary)
                              : context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const DatePickerWidget(),
        ],
      ),
    );
  }
}
