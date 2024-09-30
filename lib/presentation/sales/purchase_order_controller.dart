import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/dal/services/purchase_order_service.dart';
import '../../infrastructure/models/invoice_sales_model.dart';
import '../../infrastructure/models/purchase_order_model.dart';
import 'buy_product_widget/buy_product_controller.dart';
import 'controllers/sales.controller.dart';
import 'print_purchase_order_dialog.dart';

class PurchaseOrderController extends GetxController {
  final PurchaseOrderService _purchaseOrderService =
      Get.find<PurchaseOrderService>();
  final BuyProductController _buyProductC = Get.put(BuyProductController());
  late SalesController salesC = Get.find();

  late final purchaseOrder = _purchaseOrderService.purchaseOrder;
  late final foundPurchaseOrder = _purchaseOrderService.foundPurchaseOrder;

  // void filterpurchaseOrder(String customerName) {
  //   _purchaseOrderService.search(customerName);
  // }

  destroyHandle(PurchaseOrderModel purchaseOrder) async {
    Get.defaultDialog(
      title: 'Hapus',
      middleText: 'Hapus PO ini?',
      confirm: TextButton(
        onPressed: () async {
          await _purchaseOrderService.delete(purchaseOrder.id!);
          Get.back();
          Get.back();
        },
        child: const Text('OK'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  Future savePurchaseOrder(PurchaseOrderModel purchaseOrder,
      {bool isEdit = false}) async {
    // final purchaseOrder = PurchaseOrderModel(
    //   purchaseList: salesInvoice.purchaseList.value,
    //   storeId: salesInvoice.storeId,
    //   orderId: salesInvoice.invoiceId,
    //   createdAt: salesInvoice.createdAt.value,
    //   sales: salesC.selectedSales.value,
    // );
    Get.defaultDialog(
      title: 'Menyimpan Purchase Order...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      var purchaseOrderPrint =
          PurchaseOrderModel.fromJson(purchaseOrder.toJson());
      if (isEdit) {
        await _purchaseOrderService.update(purchaseOrder);
        _buyProductC.clear();
        Get.back();
        Get.back();
        // _buyProductC.clear();
      } else {
        // print(purchaseOrder.toJson());
        await _purchaseOrderService.insert(purchaseOrder);
        _buyProductC.clear();
        Get.back();
        Get.back();
      }

      Get.back();

      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Purchase Order berhasil disimpan.',
        confirm: SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.primaryColor)
                .copyWith(
                    textStyle: WidgetStateProperty.all(
                        const TextStyle(fontWeight: FontWeight.normal)),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12.0))),
            onPressed: () async {
              // Get.back();
              printPurchaseOrderDialog(purchaseOrderPrint);
            },
            child: const Text('Cetak Invoice'),
          ),
        ),
        cancel: SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey)
                .copyWith(
                    textStyle: WidgetStateProperty.all(
                        const TextStyle(fontWeight: FontWeight.normal)),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12.0))),
            onPressed: () async {
              Get.back();
            },
            child: const Text('Kembali'),
          ),
        ),
      );
    } catch (e) {
      await Get.defaultDialog(
        title: 'Gagal Menyimpan Purchase Order!',
        middleText: e.toString(),
      );
      Get.back();
      Get.back();
    }
  }
}
