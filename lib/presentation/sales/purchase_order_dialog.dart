import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/purchase_order_model.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/popup_page_widget.dart';

import 'purchase_order_controller.dart';
import 'purchase_order_detail.dart';

void purchaseOrderDialog() async {
  final PurchaseOrderController controller = Get.put(PurchaseOrderController());

  showPopupPageWidget(
    title: 'Purchase Order',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.85),
    content: SizedBox(
      height: MediaQuery.of(Get.context!).size.height * (0.65),
      child: Column(
        children: [
          const TableHeader(),
          Divider(color: Colors.grey[500]),
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
      leading: SizedBox(
        width: 50,
        child: Text(
          'No',
          style: context.textTheme.headlineSmall,
        ),
      ),
      title: Row(
        children: [
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
            flex: 6,
            child: SizedBox(
              child: Text(
                'Estimasi harga',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
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
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: Text(
          (index + 1).toString(),
          style: context.textTheme.bodySmall,
        ),
      ),
      title: Row(
        children: [
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
            child: SizedBox(
              child: Text(
                currency
                    .format(foundPurchaseOrder.purchaseList.value.subtotalCost),
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      // trailing: controller.isAdmin
      //     ? Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 4),
      //         child: IconButton(
      //           onPressed: () => controller.destroyHandle(foundPurchaseOrder),
      //           icon: const Icon(
      //             Symbols.delete,
      //             color: Colors.red,
      //           ),
      //         ),
      //       )
      //     : null,
      onTap: () => purchaseOrderDetail(purchaseOrder: foundPurchaseOrder),
    );
  }
}
