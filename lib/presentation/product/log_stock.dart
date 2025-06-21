import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/log_stock_model.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/popup_page_widget.dart';
import 'daily_product_sold.dart';

void logStock(List<LogStock> logStock,
    {bool isSingle = false, bool isNow = false}) {
  print('logStock.lenght ${logStock.length}');
  // Urutkan log berdasarkan tanggal dari yang paling baru ke yang terlama untuk tampilan
  logStock.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

  // Salin logStock dan urutkan dari yang terlama ke yang terbaru untuk perhitungan balance
  // List<LogStock> logStockForBalance = List.from(logStock)
  //   ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

  showPopupPageWidget(
      title: isNow ? 'Stok Hari ini' : 'Histori perubahan stok',
      height: MediaQuery.of(Get.context!).size.height * (vertical ? 0.6 : 0.9),
      width: MediaQuery.of(Get.context!).size.width * (vertical ? 0.6 : 0.4),
      content: Expanded(
        child: isNow
            ? DailyProductSold(logStock: logStock)
            : ListView.builder(
                itemCount:
                    logStock.toSet().map((e) => e.productName).toSet().length,
                itemBuilder: (context, index) {
                  final productName = logStock
                      .toSet()
                      .map((e) => e.productName)
                      .toSet()
                      .elementAt(index);

                  final logs = logStock
                      .where((log) => log.productName == productName)
                      .toList();
                  // print('aaaaLogs ${aaaaLogs?.toJson()}');

                  return logs.isEmpty
                      ? SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                productName ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...logs.map((log) {
                              List<LogStock> reverselogs = List.from(logs)
                                ..sort((a, b) =>
                                    a.createdAt!.compareTo(b.createdAt!));
                              double balance = logStock
                                      .firstWhereOrNull((log) =>
                                          log.label == 'Stok Awal' ||
                                          log.label == 'Update')
                                      ?.amount ??
                                  0;

                              print('balance first $balance');

                              for (var item in reverselogs) {
                                // final item = logs[i];
                                if ((item.createdAt!.isBefore(log.createdAt!) ||
                                    item.createdAt!
                                        .isAtSameMomentAs(log.createdAt!))) {
                                  if (item.label == 'Stok Awal' ||
                                      item.label == 'Update') {
                                    balance = item.amount;
                                  } else {
                                    balance += item.amount;
                                  }
                                }
                              }
                              return Column(
                                children: [
                                  ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dateShortMonth
                                                  .format(log.createdAt!),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text('Sisa: ${number.format(balance)}'),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(log.label ?? '',
                                              style: TextStyle(fontSize: 12)),
                                          Text(
                                              '${(log.label == 'Stok Awal' || log.label == 'Update') ? 'Diubah: ' : (log.amount < 0 ? 'Jumlah: ' : 'Jumlah: +')}${number.format(log.amount)}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(color: Colors.grey[300]),
                                ],
                              );
                            }),
                          ],
                        );
                },
              ),
      )
      //  !vertical
      // ? Expanded(
      //     child: SingleChildScrollView(
      //       child: DataTable(
      //         columns: <DataColumn>[
      //           DataColumn(label: Text('Tanggal')),
      //           DataColumn(label: Text('Produk')),
      //           DataColumn(label: Text('Label')),
      //           DataColumn(label: Text('Jumlah')),
      //           if (isSingle) DataColumn(label: Text('Sisa')),
      //         ],
      //         rows: logStock
      //             .asMap()
      //             .map((idx, log) {
      //               double balance = 0;

      //               // Hitung saldo stok dari urutan terlama ke terbaru
      //               if (isSingle) {
      //                 for (var item in logStockForBalance) {
      //                   if (item.createdAt!.isBefore(log.createdAt!) ||
      //                       item.createdAt!
      //                           .isAtSameMomentAs(log.createdAt!)) {
      //                     if (item.label == 'Stok Awal' ||
      //                         item.label == 'Update') {
      //                       balance = item.amount;
      //                     } else {
      //                       balance += item.amount;
      //                     }
      //                   }
      //                 }
      //               }

      //               return MapEntry(
      //                   idx,
      //                   DataRow(
      //                     cells: <DataCell>[
      //                       DataCell(Text(date.format(log.createdAt!))),
      //                       DataCell(Text(log.productName ?? '')),
      //                       DataCell(Text(log.label ?? '')),
      //                       DataCell(Text(
      //                           '${((log.label == 'Stok Awal') || (log.label == 'Update')) ? '' : (log.amount < 0) ? '' : '+'}${number.format(log.amount)}')),
      //                       if (isSingle)
      //                         DataCell(Text(number.format(balance))),
      //                     ],
      //                   ));
      //             })
      //             .values
      //             .toList(),
      //       ),
      //     ),
      //   )
      // : Expanded(
      //     child: ListView.builder(
      //       itemCount:
      //           logStock.toSet().map((e) => e.productName).toSet().length,
      //       itemBuilder: (context, index) {
      //         final productName = logStock
      //             .toSet()
      //             .map((e) => e.productName)
      //             .toSet()
      //             .elementAt(index);
      //         final logs = logStock
      //             .where((log) => log.productName == productName)
      //             .toList();
      //         return Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Text(
      //                 productName ?? '',
      //                 style: TextStyle(
      //                   fontSize: 16,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //             ...logs.map((log) {
      //               // var reverselogs = logs.reversed.toList();
      //               List<LogStock> reverselogs = List.from(logs)
      //                 ..sort(
      //                     (a, b) => a.createdAt!.compareTo(b.createdAt!));
      //               double balance = logStock
      //                       .firstWhereOrNull((log) =>
      //                           log.label == 'Stok Awal' ||
      //                           log.label == 'Update')
      //                       ?.amount ??
      //                   0;

      //               print('balance first $balance');

      //               for (var item in reverselogs) {
      //                 // final item = logs[i];
      //                 if ((item.createdAt!.isBefore(log.createdAt!) ||
      //                     item.createdAt!
      //                         .isAtSameMomentAs(log.createdAt!))) {
      //                   if (item.label == 'Stok Awal' ||
      //                       item.label == 'Update') {
      //                     balance = item.amount;
      //                   } else {
      //                     balance += item.amount;
      //                   }
      //                 }
      //               }
      //               return ListTile(
      //                 title: Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         Text(
      //                           dateShortMonth.format(log.createdAt!),
      //                           style: TextStyle(
      //                             fontSize: 12,
      //                             fontStyle: FontStyle.italic,
      //                             color: Colors.grey[600],
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                     Text('Sisa: ${number.format(balance)}'),
      //                   ],
      //                 ),
      //                 subtitle: Padding(
      //                   padding: const EdgeInsets.symmetric(vertical: 4),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Text(log.label ?? '',
      //                           style: TextStyle(fontSize: 12)),
      //                       Text(
      //                           'Jumlah: ${(log.label == 'Stok Awal' || log.label == 'Update') ? '' : (log.amount < 0 ? '' : '+')}${number.format(log.amount)}'),
      //                     ],
      //                   ),
      //                 ),
      //               );
      //             }),
      //           ],
      //         );
      //       },
      //     ),
      //   )
      // : Expanded(
      //     child: ListView.separated(
      //       separatorBuilder: (context, index) =>
      //           Divider(color: Colors.grey[300]),
      //       shrinkWrap: true,
      //       itemCount: logStock.length,
      //       itemBuilder: (context, index) {
      //         final log = logStock[index];
      //         double balance = 0;
      //         if (isSingle) {
      //           for (var item in logStockForBalance) {
      //             if (item.createdAt!.isBefore(log.createdAt!) ||
      //                 item.createdAt!.isAtSameMomentAs(log.createdAt!)) {
      //               if (item.label == 'Stok Awal' ||
      //                   item.label == 'Update') {
      //                 balance = item.amount;
      //               } else {
      //                 balance += item.amount;
      //               }
      //             }
      //           }
      //         }
      //         return ListTile(
      //           title: Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text(
      //                     log.productName ?? '',
      //                     style: TextStyle(
      //                       fontSize: 14,
      //                       fontStyle: FontStyle.italic,
      //                     ),
      //                   ),
      //                   Text(
      //                     dateShortMonth.format(log.createdAt!),
      //                     style: TextStyle(
      //                       fontSize: 12,
      //                       fontStyle: FontStyle.italic,
      //                       color: Colors.grey[600],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               if (isSingle) Text('Sisa: ${number.format(balance)}'),
      //             ],
      //           ),
      //           subtitle: Padding(
      //             padding: const EdgeInsets.symmetric(vertical: 8),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               // crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 // Text('Label: ${log.label ?? ''}'),
      //                 Text(log.label ?? '',
      //                     style: TextStyle(fontSize: 12)),
      //                 Text(
      //                     'Jumlah: ${(log.label == 'Stok Awal' || log.label == 'Update') ? '' : (log.amount < 0 ? '' : '+')}${number.format(log.amount)}'),
      //               ],
      //             ),
      //           ),
      //         );
      //       },
      //     ),
      //   ),
      );
}
