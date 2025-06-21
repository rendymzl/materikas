// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:material_symbols_icons/symbols.dart';

// import '../../../infrastructure/models/purchase_order_model.dart';
// import '../../../infrastructure/navigation/routes.dart';
// import '../../../infrastructure/utils/display_format.dart';
// import '../print_purchase_order_dialog.dart';
// import '../purchase_order_controller.dart';
// import '../purchase_order_detail.dart';

// class PurchaseOrderView extends GetView {
//   const PurchaseOrderView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final PurchaseOrderController controller =
//         Get.put(PurchaseOrderController());

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text('Purchase Order'),
//         centerTitle: true,
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Obx(
//             () => ListView.separated(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               separatorBuilder: (context, index) =>
//                   Divider(color: Colors.grey[300]),
//               itemCount: controller.foundPurchaseOrder.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final foundPurchaseOrder = controller.foundPurchaseOrder[index];
//                 return TableContent(
//                   foundPurchaseOrder: foundPurchaseOrder,
//                   index: index,
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.all(8),
//             child: ElevatedButton(
//               onPressed: () => Get.toNamed(Routes.INVOICE_PRODUCT_LIST),
//               child: const Text('Tambah Daftar PO'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TableContent extends StatelessWidget {
//   const TableContent({
//     super.key,
//     required this.foundPurchaseOrder,
//     required this.index,
//   });

//   final PurchaseOrderModel foundPurchaseOrder;
//   final int index;

//   @override
//   Widget build(BuildContext context) {
//     final PurchaseOrderController controller = Get.find();
//     return Card(
//       color: Colors.grey[100],
//       child: Column(
//         children: [
//           ListTile(
//               title: Row(
//                 children: [
//                   SizedBox(
//                     width: 70,
//                     child: Text(
//                       (index + 1).toString(),
//                       style: context.textTheme.bodySmall,
//                     ),
//                   ),
//                   Expanded(
//                     flex: 8,
//                     child: Container(
//                       padding: const EdgeInsets.only(right: 30),
//                       child: Text(
//                         foundPurchaseOrder.orderId ?? '',
//                         style: context.textTheme.titleMedium,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 6,
//                     child: Container(
//                       padding: const EdgeInsets.only(right: 30),
//                       child: Text(
//                         foundPurchaseOrder.sales.value!.name ?? '',
//                         style: context.textTheme.titleMedium,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 4,
//                     child: SizedBox(
//                       child: Text(
//                         'Rp ${currency.format(foundPurchaseOrder.purchaseList.value.subtotalCost)}',
//                         style: context.textTheme.titleMedium,
//                         // textAlign: TextAlign.end,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               trailing: SizedBox(
//                 width: 100,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: IconButton(
//                           onPressed: () => purchaseOrderDetail(
//                               purchaseOrder: foundPurchaseOrder),
//                           icon: const Icon(
//                             Symbols.edit_square,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: IconButton(
//                           onPressed: () =>
//                               printPurchaseOrderDialog(foundPurchaseOrder),
//                           icon: const Icon(
//                             Symbols.print,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//           Container(
//             decoration: BoxDecoration(
//                 color: Colors.white, borderRadius: BorderRadius.circular(8)),
//             margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
//             child: ListView.builder(
//               shrinkWrap: true,
//               // separatorBuilder: (context, index) =>
//               //     Divider(color: Colors.grey[300]),
//               itemCount: foundPurchaseOrder.purchaseList.value.items.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final purchaseOrder =
//                     foundPurchaseOrder.purchaseList.value.items[index];
//                 return ListTile(
//                   title: Row(
//                     children: [
//                       SizedBox(
//                         width: 70,
//                         child: Text(
//                           (index + 1).toString(),
//                           style: context.textTheme.bodySmall,
//                         ),
//                       ),
//                       Expanded(
//                         flex: 5,
//                         child: Container(
//                           padding: const EdgeInsets.only(right: 30),
//                           child: Text(
//                             purchaseOrder.product.productName,
//                             style: context.textTheme.bodySmall,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 3,
//                         child: Container(
//                           padding: const EdgeInsets.only(right: 30),
//                           child: Text(
//                             '${number.format(purchaseOrder.quantity.value)} ${purchaseOrder.product.unit}',
//                             style: context.textTheme.bodySmall,
//                           ),
//                         ),
//                       ),
//                       // Expanded(
//                       //   flex: 6,
//                       //   child: SizedBox(
//                       //     child: Text(
//                       //       currency.format(foundPurchaseOrder
//                       //           .purchaseList.value.subtotalCost),
//                       //       style: context.textTheme.titleMedium,
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
