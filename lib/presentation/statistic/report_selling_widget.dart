import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/properties_row_widget.dart';
import 'controllers/statistic.controller.dart';

class ReportSellingWidget extends StatelessWidget {
  const ReportSellingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () {
          final data = controller.selectedChart.value;

          return Column(
            children: [
              Text(
                'DETAIL TRANSAKSI PENJUALAN',
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge!
                    .copyWith(color: Get.theme.primaryColor),
              ),
              Divider(color: Colors.grey[400], thickness: 2),
              controller.isLoading.value
                  ? Expanded(child: Center(child: CircularProgressIndicator()))
                  : data == null
                      ? Text('Tidak ada data')
                      : Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total Invoice: ${data.totalInvoice}',
                                    style: Get.textTheme.titleLarge,
                                  )
                                ],
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Text(data.dateString),
                              //     const SizedBox(width: 12),
                              //     Text('Total Invoice: ${data.totalInvoice}'),
                              //   ],
                              // ),
                              PropertiesRowWidget(
                                title: 'Total Penjualan',
                                value: currency.format(data.totalBill),
                                primary: true,
                              ),
                              PropertiesRowWidget(
                                title: 'Total Diskon',
                                value: 'title',
                                subValue:
                                    '-${currency.format(data.totalDiscount)}',
                                color: Colors.red,
                              ),

                              PropertiesRowWidget(
                                title: 'Penjualan Bersih',
                                value: currency.format(data.finalBill),
                                primary: true,
                              ),
                              Divider(color: Colors.grey[400]),
                              PropertiesRowWidget(
                                title: 'Modal Pokok',
                                value: 'title',
                                subValue: '-${currency.format(data.totalCost)}',
                                color: Colors.red,
                              ),
                              if (data.totalReturn > 0)
                                PropertiesRowWidget(
                                  title: 'Total Return',
                                  value: 'title',
                                  subValue:
                                      '-${currency.format(data.totalReturn)}',
                                  color: Colors.red,
                                ),
                              if (data.returnFee > 0)
                                PropertiesRowWidget(
                                  title: 'Biaya Return',
                                  value: 'title',
                                  subValue:
                                      '+${currency.format(data.returnFee)}',
                                  color: Colors.green,
                                ),
                              PropertiesRowWidget(
                                title: 'Laba Kotor',
                                value: currency.format(data.grossProfit),
                                primary: true,
                              ),
                              Divider(color: Colors.grey[400]),
                              PropertiesRowWidget(
                                title: 'Biaya Operasional',
                                value: 'title',
                                subValue:
                                    '-${currency.format(data.totalOperatingCost)}',
                                color: Colors.red,
                              ),

                              PropertiesRowWidget(
                                title: 'Laba Bersih',
                                value: currency.format(data.cleanProfit),
                                primary: true,
                              ),

                              Divider(color: Colors.grey[400]),
                              // Divider(color: Colors.red[400]),
                              Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    PropertiesRowWidget(
                                      title: 'Penjualan Bersih',
                                      value: currency.format(data.finalBill),
                                      primary: true,
                                    ),
                                    PropertiesRowWidget(
                                      title: 'Dibayar',
                                      value: currency.format(data.income),
                                      primary: true,
                                    ),
                                    PropertiesRowWidget(
                                      title: 'Belum Bayar',
                                      value: currency.format(data.notYetPaid),
                                      primary: true,
                                    ),
                                  ],
                                ),
                              ),

                              // Divider(color: Colors.red[400]),
                              // PropertiesRowWidget(
                              //   title: 'Total Penjualan',
                              //   value: currency.format(data.totalBill),
                              //   primary: true,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Total Diskon',
                              //   value:
                              //       '-${currency.format(data.totalDiscount)}',
                              //   color: Colors.red,
                              // ),
                              // // if (data.totalOtherCost > 0)
                              // //   PropertiesRowWidget(
                              // //     title: 'Total Biaya Lainnya',
                              // //     value: currency.format(data.totalOtherCost),
                              // //     color: Colors.green,
                              // //   ),
                              // if (data.totalReturn > 0)
                              //   const PropertiesRowWidget(
                              //     title: 'Return',
                              //     value: 'title',
                              //     primary: true,
                              //   ),
                              // if (data.totalReturn > 0)
                              //   PropertiesRowWidget(
                              //     title: '      - Pesanan Direturn',
                              //     value: 'title',
                              //     subValue: currency
                              //         .format(data.totalReturn * -1),
                              //     italic: true,
                              //     color: Colors.red,
                              //   ),
                              // if (data.totalReturn > 0)
                              //   PropertiesRowWidget(
                              //     title: '      - Total Cas Return',
                              //     value: 'title',
                              //     subValue:
                              //         currency.format(data.returnFee),
                              //     italic: true,
                              //     color: Colors.green,
                              //   ),
                              // if (data.totalReturn > 0)
                              //   PropertiesRowWidget(
                              //     title: 'Total Return',
                              //     value: currency
                              //         .format((data.finalReturn) * -1),
                              //     color: Colors.red,
                              //   ),
                              // Divider(color: Colors.grey[400]),
                              // PropertiesRowWidget(
                              //   title: 'Penjualan Bersih',
                              //   value: currency.format(data.finalBill),
                              //   primary: true,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Modal Pokok',
                              //   value:
                              //       currency.format(data.totalCost * -1),
                              //   color: Colors.red,
                              // ),
                              // Divider(color: Colors.grey[400]),
                              // PropertiesRowWidget(
                              //   title: 'Laba Kotor',
                              //   value: currency.format(data.grossProfit),
                              //   primary: true,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Biaya Operasional',
                              //   value: currency
                              //       .format(data.totalOperatingCost * -1),
                              //   color: Colors.red,
                              // ),
                              // Divider(color: Colors.grey[400]),
                              // PropertiesRowWidget(
                              //   title: 'Laba Bersih',
                              //   value: currency.format(data.cleanProfit),
                              //   primary: true,
                              // ),
                            ],
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }
}
