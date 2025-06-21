import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/utils/display_format.dart';
import 'subs_controller.dart';

Widget selectPackageWidget() {
  final controller = Get.put(SubsController());
  return ListView.builder(
    itemCount: controller.packages.length,
    itemBuilder: (context, index) {
      final package = controller.packages[index];
      return Obx(
        () => Card(
          color: controller.selectedPackage.value?.name == package.name
              ? Theme.of(context).primaryColor
              : Colors.white,
          child: InkWell(
            onTap: () {
              // Tindakan saat paket dipilih
              controller.selectPackage(package);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text("Anda memilih paket ${package.name}"),
              //   ),
              // );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: controller.selectedPackage.value?.name ==
                                        package.name
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          if (package.durationInMonths > 1)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rp 69.000/Bulan",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: controller.selectedPackage.value
                                                  ?.name ==
                                              package.name
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                Text(
                                  "Rp 99.000/Bulan",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.lineThrough,
                                      color: controller.selectedPackage.value
                                                  ?.name ==
                                              package.name
                                          ? Colors.white70
                                          : Colors.black54),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Rp ${currency.format(package.price)}",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: controller.selectedPackage.value?.name ==
                                        package.name
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          if (package.priceBeforeDiscount != null &&
                              package.priceBeforeDiscount != package.price)
                            Text(
                              "Rp ${currency.format(package.priceBeforeDiscount!)}",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.lineThrough,
                                  color:
                                      controller.selectedPackage.value?.name ==
                                              package.name
                                          ? Colors.white70
                                          : Colors.black54),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (package.note != null && package.note!.isNotEmpty)
                    SizedBox(height: 20),
                  if (package.note != null && package.note!.isNotEmpty)
                    Text(
                      "${package.note}",
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: controller.selectedPackage.value?.name ==
                                  package.name
                              ? Colors.white70
                              : Colors.black54),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
