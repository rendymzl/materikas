import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sales.controller.dart';

class SalesInvoiceListHeader extends StatelessWidget {
  const SalesInvoiceListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller.invoiceSearchC,
            decoration: const InputDecoration(
              labelText: "Cari Invoice",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => controller.filterSalesInvoice(value),
          ),
        ),
        const SizedBox(width: 4),
        Obx(
          () => Expanded(
            flex: 5,
            child: Text(
              controller.selectedSales.value?.name ?? 'Invoice Sales',
              style:
                  Get.context!.textTheme.titleLarge!.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFilterDebt('Lunas', 'paid', controller),
            // const SizedBox(width: 12),
            _buildFilterDebt('Piutang', 'debt', controller),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDebt(
      String label, String value, SalesController controller) {
    return InkWell(
      onTap: () => controller.checkBoxHandle(value),
      child: Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Checkbox(
                  value: controller.selectedFilterCheckBox.value == value,
                  onChanged: (selected) => controller.checkBoxHandle(value),
                  splashRadius: 0,
                  side: BorderSide(
                    color: Theme.of(Get.context!).colorScheme.primary,
                    width: 2,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: controller.selectedFilterCheckBox.value == value
                          ? Theme.of(Get.context!).colorScheme.primary
                          : Theme.of(Get.context!)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7)),
                ),
              ],
            ),
          )),
    );
  }
}
