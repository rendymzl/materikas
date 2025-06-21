import 'package:flutter/material.dart';

import '../../infrastructure/models/log_stock_model.dart';
import '../../infrastructure/utils/display_format.dart';

class DailyProductSold extends StatelessWidget {
  const DailyProductSold({
    required this.logStock,
    super.key,
  });
  final List<LogStock> logStock;

  @override
  Widget build(BuildContext context) {
    // Kelompokkan log berdasarkan productName dan hitung total terjual untuk setiap produk
    Map<String, double> productTotals = {};
    for (var log in logStock) {
      if (log.label == 'Terjual') {
        productTotals[log.productName!] =
            (productTotals[log.productName!] ?? 0) + (log.amount * -1);
      }
    }

    // Urutkan produk berdasarkan total terjual dari yang terbesar ke terkecil
    List<String> sortedProducts = productTotals.keys.toList()
      ..sort((a, b) => productTotals[b]!.compareTo(productTotals[a]!));

    return ListView.builder(
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final productName = sortedProducts[index];

        final logs = logStock
            .where((log) =>
                log.productName == productName && log.label == 'Terjual')
            .toList();

        return logs.isEmpty
            ? Text('Belum ada penjualan hari ini')
            : AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                            'Terjual: ${number.format(productTotals[productName]!)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...logs.map((log) {
                      // var reverselogs = logs.reversed.toList();
                      // List<LogStock> reverselogs = List.from(logs)
                      //   ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
                      // double balance = 0;

                      // print('balance first $balance');

                      // for (var item in reverselogs) {
                      //   // final item = logs[i];
                      //   if ((item.createdAt!.isBefore(log.createdAt!) ||
                      //       item.createdAt!.isAtSameMomentAs(log.createdAt!))) {
                      //     if (item.label == 'Stok Awal' ||
                      //         item.label == 'Update') {
                      //       balance = item.amount;
                      //     } else {
                      //       balance += item.amount;
                      //     }
                      //   }
                      // }
                      return Column(
                        children: [
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateShortMonth.format(log.createdAt!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                // Text('Total: ${number.format(balance * -1)}'),
                                Text(
                                  '+ ${number.format(log.amount * -1)}',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                            // subtitle: Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 4),
                            //   child: Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text(log.label ?? '',
                            //           style: TextStyle(fontSize: 12)),
                            //       Text(number.format(log.amount * -1)),
                            //     ],
                            //   ),
                            // ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              );
      },
    );
  }
}
