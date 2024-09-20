import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/operating_cost_model.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import 'add_operating_cost.dart';
import 'controllers/operating_cost.controller.dart';
import 'date_picker_daily.dart';

class OperatingCostScreen extends GetView<OperatingCostController> {
  const OperatingCostScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MenuWidget(title: 'Operasional'),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 300,
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: DatePickerDaily(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const TableHeader(),
                          // const Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: Text(
                          //     'Biaya Operasional',
                          //   ),
                          // ),
                          Divider(color: Colors.grey[200]),
                          Expanded(
                            child: Obx(
                              () {
                                print(controller.dailyOperatingCosts.length);
                                return ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      Divider(color: Colors.grey[200]),
                                  itemCount:
                                      controller.dailyOperatingCosts.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    var operatingCost =
                                        controller.dailyOperatingCosts[index];
                                    return TableContent(
                                      index: index,
                                      operatingCost: operatingCost,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: SizedBox(
        width: 50,
        child: Text(
          'No',
          style: context.textTheme.headlineSmall,
        ),
      ),
      title: Row(
        children: [
          // Expanded(
          //   flex: 4,
          //   child: SizedBox(
          //     child: Text(
          //       'Tanggal',
          //       style: context.textTheme.headlineSmall,
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 3,
            child: SizedBox(
              child: Text(
                'Operasional',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              child: Text(
                'Jumlah Biaya',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.end,
              ),
            ),
          ),
          const Expanded(child: SizedBox(child: Text(''))),
        ],
      ),
    );
  }
}

class TableContent extends StatelessWidget {
  const TableContent(
      {super.key, required this.index, required this.operatingCost});

  final int index;
  final OperatingCostModel operatingCost;

  @override
  Widget build(BuildContext context) {
    OperatingCostController controller = Get.find();

    return ListTile(
      dense: true,
      leading: SizedBox(
        width: 50,
        child: Text(
          (index + 1).toString(),
          style: context.textTheme.bodySmall,
        ),
      ),
      title: Row(
        children: [
          // Expanded(
          //   flex: 4,
          //   child: Container(
          //     padding: const EdgeInsets.only(right: 30),
          //     child: Text(
          //       DateFormat('dd/MMM HH:mm', 'id')
          //           .format(operatingCost.createdAt!),
          //       style: context.textTheme.titleMedium,
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 3,
            child: SizedBox(
              child: Text(
                operatingCost.name ?? '',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              child: Text(
                'Rp${currency.format(operatingCost.amount ?? 0)}',
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.end,
              ),
            ),
          ),
          const Expanded(child: SizedBox(child: Text(''))),
          IconButton(
            onPressed: () async => await Get.defaultDialog(
              title: 'Hapus',
              middleText: 'Hapus Biaya?',
              confirm: TextButton(
                onPressed: () async {
                  controller.deleteOperatingCost(operatingCost);
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
                  style: TextStyle(color: Colors.black.withOpacity(0.5)),
                ),
              ),
            ),
            icon: const Icon(
              Symbols.delete_forever,
              color: Colors.red,
            ),
          ),
        ],
      ),
      subtitle: operatingCost.note != null ? Text(operatingCost.note!) : null,
    );
  }
}
