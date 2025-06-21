import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: isMobile ? Colors.white : null,
        appBar: isMobile
            ? AppBar(
                title: const Text("Operasional"),
                centerTitle: true,
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                actions: isMobile
                    ? [
                        IconButton(
                            icon: Icon(Symbols.date_range),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 300,
                                        height: 480,
                                        child: SfDateRangePicker(
                                          navigationDirection:
                                              DateRangePickerNavigationDirection
                                                  .vertical,
                                          navigationMode:
                                              DateRangePickerNavigationMode
                                                  .scroll,
                                          headerStyle:
                                              DateRangePickerHeaderStyle(
                                                  backgroundColor: Colors.white,
                                                  textStyle: context
                                                      .textTheme.bodyLarge),
                                          backgroundColor: Colors.white,
                                          enableMultiView: true,
                                          initialSelectedDate:
                                              controller.selectedDate.value,
                                          monthViewSettings:
                                              const DateRangePickerMonthViewSettings(
                                            firstDayOfWeek: 1,
                                          ),
                                          selectionMode:
                                              DateRangePickerSelectionMode
                                                  .single,
                                          minDate: DateTime(2000),
                                          maxDate: DateTime.now(),
                                          showActionButtons: true,
                                          cancelText: 'Batal',
                                          onCancel: () => Get.back(),
                                          onSubmit: (p0) async {
                                            controller.rangePickerHandle(
                                                p0 as DateTime);
                                            Get.back();
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            })
                      ]
                    : null,
              )
            : null,
        drawer: isMobile ? buildDrawer(context) : null,
        body: Column(
          children: [
            if (!isMobile) const MenuWidget(title: 'Operasional'),
            Expanded(
              child: isMobile
                  ? buildMobileLayout(context)
                  : buildDesktopLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk tampilan desktop
  Widget buildDesktopLayout(BuildContext context) {
    // controller.isMobile.value = false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 300,
            child: Card(
              elevation: 0,
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
              elevation: 0,
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
                            itemCount: controller.dailyOperatingCosts.length,
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
    );
  }

  // Fungsi untuk tampilan mobile
// Fungsi untuk tampilan mobile
  Widget buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Symbols.arrow_left),
                  onPressed: () {
                    controller.rangePickerHandle(controller.selectedDate.value
                        .subtract(Duration(days: 1)));
                    // controller.selectedDate.value = controller
                    //     .selectedDate.value
                    //     .subtract(Duration(days: 1));
                  },
                ),
                Text(
                  DateFormat('dd MMMM y', 'id')
                      .format(controller.selectedDate.value),
                ),
                IconButton(
                  icon: const Icon(Symbols.arrow_right),
                  onPressed: () {
                    final nextDate =
                        controller.selectedDate.value.add(Duration(days: 1));
                    if (!nextDate.isAfter(DateTime.now())) {
                      controller.rangePickerHandle(nextDate);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        // Bagian untuk memilih tanggal
        // const Padding(
        //   padding: EdgeInsets.all(8.0),
        //   child: DatePickerDaily(
        //     isPopUp: true,
        //   ),
        // ),
        // Header tabel untuk nama biaya operasional dan jumlahnya
        // const TableHeader(),
        Divider(color: Colors.grey[200]),
        // Daftar biaya operasional
        Expanded(
          child: Obx(
            () {
              return ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[200]),
                itemCount: controller.dailyOperatingCosts.length,
                itemBuilder: (context, index) {
                  var operatingCost = controller.dailyOperatingCosts[index];
                  return TableContent(
                    index: index,
                    operatingCost: operatingCost,
                  );
                },
              );
            },
          ),
        ),
        // Tombol untuk menambah biaya operasional
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => addOperatingCostDialog(),
            style: ElevatedButton.styleFrom(
              minimumSize:
                  Size(double.infinity, 48), // Membuat tombol full-width
            ),
            child: const Text(
              'Tambah Biaya Operasional',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
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
        // width: 50,
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
      subtitle: (operatingCost.note != null && operatingCost.note!.isNotEmpty)
          ? Text(operatingCost.note!)
          : null,
    );
  }
}
