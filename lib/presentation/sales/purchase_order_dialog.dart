import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/purchase_order_model.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/popup_page_widget.dart';

import 'print_purchase_order_dialog.dart';
import 'purchase_order_controller.dart';
import 'purchase_order_detail.dart';

void purchaseOrderDialog() async {
  final PurchaseOrderController controller = Get.put(PurchaseOrderController());

  showPopupPageWidget(
    title: 'Purchase Order',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.50),
    content: SizedBox(
      height: MediaQuery.of(Get.context!).size.height * (0.65),
      child: Column(
        children: [
          // const TableHeader(),
          // Divider(color: Colors.grey[500]),
          Expanded(
            child: Obx(
              () => ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[300]),
                itemCount: controller.foundPurchaseOrder.length,
                itemBuilder: (BuildContext context, int index) {
                  final foundPurchaseOrder =
                      controller.foundPurchaseOrder[index];
                  return TableContent(
                    foundPurchaseOrder: foundPurchaseOrder,
                    index: index,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
    buttonList: [
      Row(
        children: [
          ElevatedButton(
            onPressed: () => purchaseOrderDetail(),
            child: const Text('Tambah PO'),
          ),
        ],
      ),
    ],
  );
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              'No',
              style: context.textTheme.headlineSmall,
            ),
          ),
          Expanded(
            flex: 8,
            child: SizedBox(
              child: Text(
                'Purchase order',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Sales',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Estimasi harga',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
      trailing: const SizedBox(width: 40),
    );
  }
}

class TableContent extends StatelessWidget {
  const TableContent({
    super.key,
    required this.foundPurchaseOrder,
    required this.index,
  });

  final PurchaseOrderModel foundPurchaseOrder;
  final int index;

  @override
  Widget build(BuildContext context) {
    final PurchaseOrderController controller = Get.find();
    return Card(
      color: Colors.grey[100],
      child: Column(
        children: [
          ListTile(
              title: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      (index + 1).toString(),
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        foundPurchaseOrder.orderId ?? '',
                        style: context.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        foundPurchaseOrder.sales.value!.name ?? '',
                        style: context.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      child: Text(
                        'Rp ${currency.format(foundPurchaseOrder.purchaseList.value.subtotalCost)}',
                        style: context.textTheme.titleMedium,
                        // textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          onPressed: () => purchaseOrderDetail(
                              purchaseOrder: foundPurchaseOrder),
                          icon: const Icon(
                            Symbols.edit_square,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          onPressed: () =>
                              printPurchaseOrderDialog(foundPurchaseOrder),
                          icon: const Icon(
                            Symbols.print,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: ListView.builder(
              shrinkWrap: true,
              // separatorBuilder: (context, index) =>
              //     Divider(color: Colors.grey[300]),
              itemCount: foundPurchaseOrder.purchaseList.value.items.length,
              itemBuilder: (BuildContext context, int index) {
                final purchaseOrder =
                    foundPurchaseOrder.purchaseList.value.items[index];
                return ListTile(
                  title: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          (index + 1).toString(),
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.only(right: 30),
                          child: Text(
                            purchaseOrder.product.productName,
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.only(right: 30),
                          child: Text(
                            '${number.format(purchaseOrder.quantity.value)} ${purchaseOrder.product.unit}',
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                      ),
                      // Expanded(
                      //   flex: 6,
                      //   child: SizedBox(
                      //     child: Text(
                      //       currency.format(foundPurchaseOrder
                      //           .purchaseList.value.subtotalCost),
                      //       style: context.textTheme.titleMedium,
                      //     ),
                      //   ),
                      // ),
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
