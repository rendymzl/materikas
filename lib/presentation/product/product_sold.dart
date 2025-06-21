// file: product_sold_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Sesuaikan path import Anda
import '../../infrastructure/models/log_stock_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'detail_sold.dart';
import 'product_sold_controller.dart'; // <-- IMPORT CONTROLLER

class ProductSold extends StatelessWidget {
  const ProductSold({
    required this.logStock,
    super.key,
  });
  final List<LogStock> logStock;

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller dengan data logStock.
    // GetX akan cukup pintar untuk tidak membuat ulang jika sudah ada.
    final ProductSoldController controller =
        Get.put(ProductSoldController(logStock));

    return Column(
      children: [
        // Bungkus list dengan Obx agar otomatis update saat data di controller berubah
        Expanded(
          child: Obx(() {
            if (controller.sortedProducts.isEmpty) {
              return Center(
                  child: Text('Belum ada penjualan untuk ditampilkan'));
            }

            return ListView.builder(
              itemCount: controller.sortedProducts.length,
              itemBuilder: (context, index) {
                // Ambil data dari controller
                final productName = controller.sortedProducts[index];
                final productData = controller.productTotals[productName]!;

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async => await detailSold(productName),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green[50],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              productName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Terjual: ${number.format(productData['total'] as double)} ${productData['unit']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            // Panggil fungsi dari controller
            onPressed: () => controller.exportToExcel(context),
            icon: const Icon(Icons.download),
            label: const Text('Export ke Excel'),
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.green,
            //   foregroundColor: Colors.white,
            // ),
          ),
        ),
      ],
    );
  }
}
