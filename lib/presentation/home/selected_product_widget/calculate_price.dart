import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/payment_widget/payment_widget.dart';
import '../controllers/home.controller.dart';

class CalculatePrice extends StatelessWidget {
  const CalculatePrice({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Obx(
              () {
                final cart = controller.cart.value;
                final cartItems = cart.items;
                return SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PropertiesRowWidget(
                        title: 'Total Harga (${cartItems.length} Barang)',
                        value: currency.format(
                          cart.getSubtotalBill(controller.priceType.value),
                        ),
                      ),
                      if (cart.totalIndividualDiscount > 0)
                        PropertiesRowWidget(
                          title: 'Total Diskon',
                          value:
                              '-${currency.format(cart.totalIndividualDiscount)}',
                        ),
                      SizedBox(
                        height: 48,
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 200,
                                child: Text('Total Belanja:',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              Text(
                                'Rp${currency.format(cart.getTotalBill(controller.priceType.value))}',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (cart.getTotalBill(
                                          controller.priceType.value) >
                                      0) {
                                    InvoiceModel invoice =
                                        await controller.createInvoice();
                                    print(invoice.toJson());
                                    paymentWidget(invoice);
                                    // if (context.mounted) {
                                    // paymentStep(
                                    //   context,
                                    //   invoice,
                                    // );
                                    // }
                                  } else {
                                    Get.defaultDialog(
                                      title: 'Error',
                                      middleText:
                                          'Tidak ada Barang yang ditambahkan.',
                                      confirm: TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('OK'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Pilih Pembayaran')),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PropertiesRowWidget extends StatelessWidget {
  const PropertiesRowWidget({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.primary,
    this.color,
  });

  final String title;
  final String value;
  final String? subValue;
  final bool? primary;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: primary != null && primary == true
                          ? context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold, color: color)
                          : context.textTheme.titleMedium!
                              .copyWith(color: color)),
                  Row(
                    children: [
                      Text(
                        subValue ?? '',
                        style: context.textTheme.bodySmall!.copyWith(
                            fontStyle: FontStyle.italic,
                            // decoration: TextDecoration.lineThrough,
                            color: color),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              value == '0' || value == '-0' ? '-' : 'Rp$value',
              style: primary != null && primary == true
                  ? context.textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.bold, color: color)
                  : context.textTheme.titleMedium!.copyWith(color: color),
            )
          ],
        ),
      ),
    );
  }
}
