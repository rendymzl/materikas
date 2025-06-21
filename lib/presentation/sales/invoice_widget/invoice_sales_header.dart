import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../global_widget/date_picker_widget/date_picker_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';

class InvoiceSalesHeader extends StatelessWidget {
  const InvoiceSalesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    late BuyProductController controller = Get.find();
    var textIdC = TextEditingController();
    controller.createdAt(DateTime.now());

    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FilterChip(
            label: Text('Pesanan PO',
                style: TextStyle(fontWeight: FontWeight.bold)),
            selected: controller.isPurchaseOrder.value,
            onSelected: (selected) => controller.purchaseOrderHandle(),
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: textIdC,
              decoration: InputDecoration(
                labelText: controller.isPurchaseOrder.value
                    ? "ID Purchase Order"
                    : "ID/Nama Invoice",
                prefixIcon: const Icon(Symbols.numbers),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => controller.nomorInvoice.value = value,
            ),
          ),
          const SizedBox(width: 16),
          DatePickerWidget(dateTime: controller.createdAt),
        ],
      ),
    );
  }
}
