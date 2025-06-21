import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/invoice.controller.dart';
import '../widget/invoice_list_vertical.dart';
import '../widget/invoice_header.dart';

class InvoiceVerticalLayout extends StatelessWidget {
  final InvoiceController controller;

  const InvoiceVerticalLayout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InvoiceHeader(controller: controller),
            const SizedBox(height: 6),
            Obx(
              () => (controller.displayFilteredDate.value != '')
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              controller.handleFilteredDate(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Obx(
                                () => Text(
                                  maxLines: 2,
                                  controller.displayFilteredDate.value == ''
                                      ? 'Pilih Tanggal'
                                      : controller.displayFilteredDate.value,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (controller.dateIsSelected.value)
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              controller.clearHandle();
                            },
                          ),
                      ],
                    )
                  : SizedBox(),
            ),
            const SizedBox(height: 6),
            _buildInvoiceStatusSummary(),
            Expanded(
              flex: 10,
              child: Obx(() => InvoiceListVertical(isDebt: controller.isDebt.value)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceStatusSummary() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(Get.context!).unfocus();
                controller.isDebt.value = false;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    controller.isDebt.value ? Colors.green[100] : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: Get.context!.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                  ),
                ),
              ),
              child: Text(
                'LUNAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: controller.isDebt.value ? Colors.grey : Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(Get.context!).unfocus();
                controller.isDebt.value = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    controller.isDebt.value ? Colors.red : Colors.red[100],
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: Get.context!.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
              child: Text(
                'BELUM LUNAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: controller.isDebt.value ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
