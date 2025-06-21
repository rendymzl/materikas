import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'print_ble_controller.dart';
import 'print_usb_controller.dart';

class PrinterSetting extends StatelessWidget {
  const PrinterSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final printerC = Get.find<PrinterUsbController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pengaturan Printer',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    IconButton(
                      onPressed: () => printerC.startScan(),
                      icon: Icon(
                        Symbols.refresh,
                        color: Theme.of(Get.context!).primaryColor,
                        fill: 1,
                      ),
                      tooltip: 'Pindai Ulang',
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
          Expanded(
            // Tambahkan Expanded di sini
            child: SingleChildScrollView(
              // SingleChildScrollView hanya untuk bagian yang perlu di-scroll
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (android) _androidPrint() else _windowsPrint(),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey[200]),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tambahan Text Cetak',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: printerC.textPromo,
                            decoration: InputDecoration(
                              hintText: "Tambahkan text",
                              hoverColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              suffixIcon: IconButton(
                                onPressed: printerC.addText,
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Theme.of(Get.context!).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (printerC.store!.textPrint!.isEmpty) {
                        return const Center(
                            child: Text('Tidak ada text tambahan'));
                      }
                      return ReorderableListView(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        onReorder: printerC.reorder,
                        padding: EdgeInsets.zero,
                        children: List.generate(
                            printerC.store!.textPrint!.length, (index) {
                          final item = printerC.store!.textPrint![index];
                          return ListTile(
                            tileColor: Colors.grey[200],
                            key: ValueKey(item),
                            title: Padding(
                              padding: const EdgeInsets.only(right: 28),
                              child: Text(item),
                            ),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.all(2),
                            leading: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                Get.defaultDialog(
                                  title: "Konfirmasi Penghapusan",
                                  middleText:
                                      "Apakah Anda yakin ingin menghapus teks ini?",
                                  textConfirm: "Ya",
                                  confirmTextColor: Colors.white,
                                  buttonColor: Colors.red,
                                  textCancel: "Tidak",
                                  onCancel: () => Get.back(),
                                  onConfirm: () async {
                                    await printerC.removeText(index);
                                    Get.back();
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      );
                    }),
                    Divider(color: Colors.grey[200]),
                    Obx(() {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          title: Row(
                            children: [
                              Icon(
                                Symbols.calendar_clock,
                                color: Theme.of(Get.context!).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tampilkan Tanggal Cetak',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          value: printerC.printDate.value,
                          onChanged: (bool? value) {
                            printerC.setPrintDate(value);
                          },
                          activeColor: Theme.of(Get.context!).primaryColor,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _androidPrint() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pilih Printer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () =>
                  Get.find<PrinterBluetoothController>().startScan(),
              icon: const Icon(
                Symbols.refresh,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Printer',
              border: OutlineInputBorder(),
            ),
            value: Get.find<PrinterBluetoothController>()
                .selectedDevice
                .value
                ?.address,
            items: Get.find<PrinterBluetoothController>()
                .devices
                .map((device) => DropdownMenuItem<String>(
                      value: device.address,
                      child: Text(
                        device.name!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: Get.find<PrinterBluetoothController>()
                    .message
                    .value
                    .toLowerCase()
                    .contains('menghubungkan')
                ? null
                : (value) {
                    var device = Get.find<PrinterBluetoothController>()
                        .devices
                        .firstWhereOrNull((d) => d.address == value);
                    if (device != null) {
                      print('Menghubungkan Printer...');
                      Get.find<PrinterBluetoothController>().connect(device);
                    }
                  },
          );
        }),
        const SizedBox(height: 12),
        Obx(() {
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Ukuran',
              border: OutlineInputBorder(),
            ),
            value: Get.find<PrinterBluetoothController>()
                    .selectedPaperSize
                    .value
                    .isEmpty
                ? null
                : Get.find<PrinterBluetoothController>()
                    .selectedPaperSize
                    .value,
            items: Get.find<PrinterBluetoothController>()
                .paperSize
                .map((size) => DropdownMenuItem<String>(
                      value: size,
                      child: Text(size),
                    ))
                .toList(),
            onChanged: Get.find<PrinterBluetoothController>()
                    .message
                    .value
                    .toLowerCase()
                    .contains('menghubungkan')
                ? null
                : (value) {
                    Get.find<PrinterBluetoothController>().setPaperSize(value!);
                  },
          );
        }),
      ],
    );
  }

  Widget _windowsPrint() {
    return Obx(() {
      final printerController = Get.find<PrinterUsbController>();

      if (printerController.initLoading.value) {
        return const Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat pengaturan printer...',
                style: TextStyle(fontSize: 14, color: Colors.grey))
          ],
        ));
      }

      if (printerController.isLoading.value) {
        return const Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mencari printer...',
                style: TextStyle(fontSize: 14, color: Colors.grey))
          ],
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final selectedPrinterName =
                printerController.selectedPrinter.value?.name;
            final availablePrinterNames =
                printerController.devices.map((d) => d.name).toList();

            if (selectedPrinterName != null &&
                !availablePrinterNames.contains(selectedPrinterName)) {
              Future.delayed(Duration.zero, () async {
                printerController.selectedPrinter.value = null;
              });
            }

            return DropdownButtonFormField<String>(
              focusColor: Colors.white,
              decoration: InputDecoration(
                  labelText: 'Pilih Printer',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1)),
                  prefixIcon: Icon(
                    Symbols.print,
                    color: Theme.of(Get.context!).primaryColor,
                    fill: 1,
                  )),
              value: printerController.selectedPrinter.value?.name,
              items: printerController.devices
                  .map((device) => DropdownMenuItem<String>(
                        value: device.name,
                        child: Text(
                          device.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: printerController.message.value
                      .toLowerCase()
                      .contains('menghubungkan')
                  ? null
                  : (value) {
                      var device = printerController.devices
                          .firstWhereOrNull((d) => d.name == value);
                      if (device != null) {
                        print('Menghubungkan Printer...');
                        printerController.connect(device);
                      }
                    },
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                title: Row(
                  children: [
                    Icon(
                      Symbols.content_copy,
                      color: Theme.of(Get.context!).primaryColor,
                      fill: 1,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cetak Rangkap',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Cetak 2 rangkap atau lebih',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            // fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                value: printerController.isDuplicate.value,
                onChanged: (bool? value) {
                  printerController.setPrintMethod(value);
                },
                activeColor: Theme.of(Get.context!).primaryColor,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final paperSizes = printerController.isDuplicate.value
                ? printerController.paperSizeDuplicate
                : printerController.paperSize;
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        color: Theme.of(Get.context!).primaryColor,
                        // size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lebar Kertas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    // Changed to Row for horizontal arrangement
                    children: paperSizes
                        .map((size) => Expanded(
                              // Added Expanded for even distribution
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: RadioListTile<String>(
                                  title: Text(size),
                                  value: size,
                                  groupValue:
                                      printerController.selectedPaperSize.value,
                                  onChanged: printerController.message.value
                                          .toLowerCase()
                                          .contains('menghubungkan')
                                      ? null
                                      : (value) {
                                          printerController
                                              .setPaperSize(value!);
                                        },
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 0),
                                  tileColor: Colors.grey[
                                      200], // Add tileColor for grey background
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}
