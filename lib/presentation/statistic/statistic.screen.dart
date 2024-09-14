import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import '../sales/selected_product_sales_widget/calculate_sales.dart';
import 'add_operating_cost.dart';
import 'controllers/statistic.controller.dart';
import 'date_picker_cart.dart';

class StatisticScreen extends GetView<StatisticController> {
  const StatisticScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MenuWidget(title: 'Laporan'),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  flex: 7,
                  child: Card(
                    child: ReportWidget(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(
                              height: 40, child: Text('Biaya Operasional')),
                          Expanded(
                            child: Obx(
                              () {
                                print(controller.dailyOperatingCosts.length);
                                return ListView.builder(
                                  itemCount:
                                      controller.dailyOperatingCosts.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    var operatingCost =
                                        controller.dailyOperatingCosts[index];
                                    return ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(operatingCost.name!),
                                          Text(
                                              'Rp${currency.format(operatingCost.amount!)}')
                                        ],
                                      ),
                                      subtitle: Text(
                                        operatingCost.note!,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      leading: IconButton(
                                        onPressed: () async =>
                                            await Get.defaultDialog(
                                          title: 'Hapus',
                                          middleText: 'Hapus Biaya?',
                                          confirm: TextButton(
                                            onPressed: () async {
                                              controller.deleteOperatingCost(
                                                  operatingCost);
                                              Get.back();
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                          cancel: TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: Text(
                                              'Batal',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.5)),
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Symbols.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => addOperatingCostDialog(),
                            child: const Text(
                              'Tambah Biaya Operasional',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: DatePickerCard(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportWidget extends StatelessWidget {
  const ReportWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () {
          final data = controller.selectedChart.value!;
          return ListView(
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.dateString),
                  const SizedBox(width: 12),
                  Text('Total Invoice: ${data.totalInvoice}'),
                ],
              ),
              PropertiesRowWidget(
                title: 'SubTotal Penjualan',
                value: currency.format(data.totalSellPrice),
                primary: true,
              ),
              PropertiesRowWidget(
                title: 'Modal Pokok',
                value: currency.format(data.totalCostPrice * -1),
                color: Colors.red,
              ),
              Divider(color: Colors.grey[400]),
              PropertiesRowWidget(
                title: 'Laba Kotor',
                value:
                    currency.format(data.totalSellPrice - data.totalCostPrice),
                primary: true,
              ),
              PropertiesRowWidget(
                title: 'Biaya Operasional',
                value: currency.format(data.operatingCost * -1),
                color: Colors.red,
              ),
              PropertiesRowWidget(
                title: 'Total Diskon',
                value: '-${currency.format(data.totalDiscount)}',
                color: Colors.red,
              ),
              PropertiesRowWidget(
                title: 'Total Cas Retur',
                value: currency.format(data.totalChargeReturn),
                color: Colors.green,
              ),
              Divider(color: Colors.grey[400]),
              PropertiesRowWidget(
                title: 'Laba Bersih',
                value: currency.format(data.cleanProfit),
                primary: true,
              ),
              const SizedBox(height: 60),
              Divider(color: Colors.grey[400], thickness: 3),
              const Text(
                'MUTASI',
                textAlign: TextAlign.center,
              ),
              Divider(color: Colors.grey[400], thickness: 3),
              PropertiesRowWidget(
                title: 'Total Penjualan',
                value: currency.format(data.totalSellPrice),
                subValue: '',
                primary: true,
              ),
              PropertiesRowWidget(
                title: 'Cash',
                value: currency.format(data.cash),
                subValue: '',
                primary: true,
                color: Colors.green,
              ),
              PropertiesRowWidget(
                title: 'Transfer',
                value: currency.format(data.transfer),
                subValue: '',
                primary: true,
                color: Colors.green,
              ),
              PropertiesRowWidget(
                title: 'Belum Bayar',
                value: currency.format(data.totalDebt - data.totalDiscount),
                subValue: data.totalDiscount > 0
                    ? 'Rp${currency.format(data.totalDebt)} - diskon Rp${currency.format(data.totalDiscount)}'
                    : '',
                primary: true,
                color: Colors.red,
              ),
              Divider(color: Colors.grey[400]),
              PropertiesRowWidget(
                title: 'Total Return',
                value: currency.format(data.totalReturn * -1),
                subValue: '',
                primary: true,
                color: Colors.red,
              ),
              PropertiesRowWidget(
                title: 'Total Diskon',
                value: currency.format(data.totalDiscount * -1),
                subValue: '',
                primary: true,
                color: Colors.red,
              ),
              PropertiesRowWidget(
                title: 'Total Cas Return',
                value: currency.format(data.totalChargeReturn),
                subValue: '',
                primary: true,
                color: Colors.green,
              ),
              PropertiesRowWidget(
                title: 'Biaya Operasional',
                value: currency.format(data.operatingCost * -1),
                color: Colors.red,
              ),
              const SizedBox(height: 30),
              PropertiesRowWidget(
                title: 'Bayar Sales Cash',
                value: currency.format(data.salesCash * -1),
                color: Colors.red,
              ),
              PropertiesRowWidget(
                title: 'Bayar Sales Transfer',
                value: currency.format(data.salesTransfer * -1),
                color: Colors.red,
              ),
              const SizedBox(height: 30),
              PropertiesRowWidget(
                title: 'Total Bayar Sales',
                value:
                    currency.format((data.salesCash + data.salesTransfer) * -1),
                color: Colors.red,
              ),
              PropertiesRowWidget(
                title: 'Sisa Uang',
                primary: true,
                value: currency.format(data.totalSellPrice -
                    data.totalDebt -
                    data.totalReturn +
                    data.totalChargeReturn -
                    data.operatingCost -
                    data.salesCash),
              ),
            ],
          );
        },
      ),
    );
  }
}
