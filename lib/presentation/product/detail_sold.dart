import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/popup_page_widget.dart';
import 'controllers/product.controller.dart';

Future detailSold(String productName) async {
  late final ProductController productC = Get.find();
  final invoices = await productC.getInvByDate();

  List<Map<String, dynamic>> result = [];

  for (var invoice in invoices) {
    for (var purchase in invoice.purchaseList.value.items) {
      if (purchase.product.productName == productName) {
        result.add({
          'customerName': invoice.customer.value?.name,
          'productName': purchase.product.productName,
          'quantity': purchase.quantity,
          'date': invoice.createdAt,
          'unit': purchase.product.unit,
        });
      }
    }
  }

  result.sort((a, b) => b['date'].value.compareTo(a['date'].value));

  showPopupPageWidget(
    title: 'Detail Penjualan $productName',
    height: MediaQuery.of(Get.context!).size.height * (0.9),
    width: MediaQuery.of(Get.context!).size.width * (0.4),
    content: Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: result.length,
        itemBuilder: (context, index) {
          final item = result[index];
          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item['customerName']}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  date.format(item['date'].value),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item['productName']}, ${item['unit']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Expanded(
                //   child: Text(
                //     '${item['productName']}',
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
                const SizedBox(width: 8),
                Text(
                  'Qty: ${number.format(item['quantity'].value)}',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            leading: const Icon(Icons.person),
          );
        },
      ),
    ),
  );
}
