import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
// import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/utils/display_format.dart';
// import '../../global_widget/print_resi/print_resi_popup.dart';
import '../controllers/invoice.controller.dart';

class InvoiceHeader extends StatelessWidget {
  final InvoiceController controller;

  const InvoiceHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // _buildIconButtonResi(),
        // const SizedBox(width: 12),
        _buildSearchBar(context),

        const SizedBox(width: 12),
        Container(width: 1, height: 42, color: Colors.grey[300]),
        // const SizedBox(width: 12),
        Row(
          children: [
            _buildPaymentMethods(context),
            Container(width: 1, height: 42, color: Colors.grey[300]),
            const SizedBox(width: 12),
            if (!vertical) _buildDateFilter(context),
          ],
        ),
        const SizedBox(width: 12),
        Container(width: 1, height: 42, color: Colors.grey[300]),
        const SizedBox(width: 12),
        if (!vertical) _buildTotalBill(context),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Expanded(
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Form(
          key: controller.formKey,
          child: TextFormField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: "Cari Invoice",
              labelStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Symbols.search),
            ),
            validator: (value) {
              if (value != null) {
                if (value.isNotEmpty && value.length < 3) {
                  return '    Ketik minimal 3 huruf';
                }
              }
              return null;
            },
            onChanged: (value) {
              controller.filterInvoices(value);
            },
          ),
        ),
      ),
    );
  }

  // Widget _buildIconButtonResi() {
  //   return SizedBox(
  //     height: 60,
  //     width: 60,
  //     child: InkWell(
  //       onTap: () {
  //         FocusScope.of(Get.context!).unfocus();
  //         printResiPopup();
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(
  //               Symbols.barcode,
  //               color: Theme.of(Get.context!).colorScheme.primary,
  //             ),
  //             const SizedBox(width: 4),
  //             Text(
  //               'Cetak Resi',
  //               style: TextStyle(
  //                 color: Theme.of(Get.context!).colorScheme.primary,
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPaymentMethods(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 12),
        _buildPaymentMethodButton(
            'cash', Icons.payments, Colors.green, Colors.green[100]!),
        const SizedBox(width: 12),
        _buildPaymentMethodButton(
            'transfer', Icons.payment, Colors.blue, Colors.blue[100]!),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildPaymentMethodButton(
      String method, IconData icon, Color color, Color hoverColor) {
    var isHovered = false.obs;
    return Obx(
      () => InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(Get.context!).unfocus();
          controller.paymentMethodHandleCheckBox(method);
        },
        child: MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: AnimatedContainer(
            width: 110,
            padding: EdgeInsets.all(8),
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: isHovered.value
                  ? hoverColor
                  : controller.methodPayment.value == method
                      ? color
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isHovered.value
                      ? Colors.grey[800]
                      : controller.methodPayment.value == method
                          ? Colors.white
                          : Colors.grey[800],
                ),
                const SizedBox(width: 4),
                Text(
                  method.capitalize!,
                  style: TextStyle(
                    color: isHovered.value
                        ? Colors.grey[800]
                        : controller.methodPayment.value == method
                            ? Colors.white
                            : Colors.grey[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async => controller.handleFilteredDate(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Obx(
              () => Text(
                controller.displayFilteredDate.value == ''
                    ? 'Pilih Tanggal'
                    : controller.displayFilteredDate.value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Obx(() => controller.dateIsSelected.value
            ? IconButton(
                onPressed: () => controller.clearHandle(),
                icon: const Icon(Icons.close, color: Colors.red),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildTotalBill(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            // color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Obx(
            () {
              final debt = controller.displayedItemsDebt;
              final paid = controller.displayedItemsPaid;

              final totalBillDebt = debt.fold<double>(
                  0,
                  (previousValue, element) =>
                      previousValue + (element.totalBill));
              final totalBillPaid = paid.fold<double>(
                  0,
                  (previousValue, element) =>
                      previousValue + (element.totalBill));

              final totalBill = totalBillDebt + totalBillPaid;
              return Text(
                'Total Belanja: Rp${currency.format(totalBill)}',
                style: Get.textTheme.bodyLarge,
              );
            },
          ),
        ),
      ],
    );
  }
}
