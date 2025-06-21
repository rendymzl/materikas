// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

// import '../../infrastructure/models/purchase_order_model.dart';
// import '../global_widget/popup_page_widget.dart';
// import '../global_widget/product_list_widget/add_product_list_widget.dart';
// import 'buy_product_widget/buy_product_controller.dart';
// import 'controllers/sales.controller.dart';
// // import 'detail_sales/payment_sales/payment_sales_controller.dart';
// import 'purchase_order_controller.dart';
// import 'selected_product_sales_widget/selected_product_sales.dart';

// void purchaseOrderDetail({PurchaseOrderModel? purchaseOrder}) async {
//   final SalesController salesC = Get.find();
//   final PurchaseOrderController purchaseOrderC =
//       Get.put(PurchaseOrderController());
//   final BuyProductController controller = Get.put(BuyProductController());
//   controller.clear();
//   salesC.clear();
//   controller.nomorInvoice.value = '';
//   // controller.filterProducts('');

//   late PurchaseOrderModel? editedPurchaseOrder;
//   if (purchaseOrder != null) {
//     editedPurchaseOrder = PurchaseOrderModel.fromJson(purchaseOrder.toJson());
//   } else {
//     editedPurchaseOrder = null;
//   }

//   showPopupPageWidget(
//     title:
//         purchaseOrder != null ? 'Edit Purchase Order' : 'Tambah Purchase Order',
//     iconButton: purchaseOrder != null
//         ? IconButton(
//             onPressed: () => purchaseOrderC.destroyHandle(purchaseOrder),
//             icon: const Icon(
//               Symbols.delete,
//               color: Colors.red,
//             ))
//         : null,
//     height: MediaQuery.of(Get.context!).size.height * (6 / 7),
//     width: MediaQuery.of(Get.context!).size.width * (0.85),
//     content: Expanded(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 3,
//             child: AddProductListWidget(
//               onClick: (product) => controller.addToCart(product),
//               isPopUp: true,
//               isSales: true,
//             ),
//           ),
//           VerticalDivider(
//             thickness: 2,
//             color: Colors.grey[200],
//           ),
//           Expanded(
//             flex: 5,
//             child: SelectedProductSales(),
//           ),
//         ],
//       ),
//     ),
//     buttonList: [
//       ElevatedButton(
//         onPressed: () async {
//           controller.editInvoice.invoiceName.value = controller.nomorInvoice.value;
//           if (controller.cart.value.items.isEmpty) {
//             Get.defaultDialog(
//               title: 'Error',
//               middleText: 'Tidak ada Barang yang ditambahkan.',
//               confirm: TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('OK'),
//               ),
//             );
//           } else if (controller.editInvoice.invoiceName == '') {
//             Get.defaultDialog(
//               title: 'Error',
//               middleText: 'Masukkan ID Purchase Order.',
//               confirm: TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('OK'),
//               ),
//             );
//           } else if (salesC.selectedSales.value == null) {
//             Get.defaultDialog(
//               title: 'Error',
//               middleText: 'Masukkan Sales.',
//               confirm: TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('OK'),
//               ),
//             );
//           } else {
//             Get.defaultDialog(
//               title: 'Simpan',
//               middleText: 'Simpan Purchase Order?',
//               confirm: TextButton(
//                 onPressed: () async {
//                   // final sales = controller.invoice.sales.value!;
//                   if (purchaseOrder != null) {
//                     editedPurchaseOrder!.orderId =
//                         controller.editInvoice.invoiceName.value;
//                     editedPurchaseOrder.sales.value =
//                         salesC.selectedSales.value;
//                     await purchaseOrderC.savePurchaseOrder(editedPurchaseOrder,
//                         isEdit: true);
//                     print('save new');
//                   } else {
//                     print('save edit');
//                     final purchaseOrder = PurchaseOrderModel(
//                       purchaseList: controller.editInvoice.purchaseList.value,
//                       storeId: controller.editInvoice.storeId,
//                       orderId: controller.editInvoice.invoiceName.value,
//                       createdAt: controller.editInvoice.createdAt.value,
//                       sales: salesC.selectedSales.value,
//                     );
//                     await purchaseOrderC.savePurchaseOrder(purchaseOrder);
//                   }

//                   Future.delayed(const Duration(milliseconds: 500),
//                       () => salesC.selectedSalesHandle(null));
//                 },
//                 child: const Text('OK'),
//               ),
//               cancel: TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Batal'),
//               ),
//             );
//           }
//         },
//         child: const Text('Simpan PO'),
//       ),
//     ],
//     onClose: () {
//       for (var cartItem in controller.initCartList) {
//         var product = controller.foundProducts.firstWhereOrNull(
//           (p) => p.id == cartItem.product.id,
//         );
//         if (product != null) {
//           product.stock.value = cartItem.product.stock.value;
//         }
//       }
//       controller.clear();
//     },
//   );
// }
