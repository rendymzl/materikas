// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../infrastructure/dal/services/auth_service.dart';
import '../../infrastructure/dal/services/operating_cost_service.dart';
import '../../infrastructure/models/operating_cost_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/operating_cost.controller.dart';

void addOperatingCostDialog() {
  late OperatingCostController controller = Get.find();
  final AuthService authService = Get.find();
  late OperatingCostService operatingCostServices = Get.find();

  final operatingCostNameTextC = TextEditingController();
  final operatingCostAmountTextC = TextEditingController();
  final operatingCostNoteTextC = TextEditingController();

  Future process() async {
    Get.defaultDialog(
      title: 'Menambahkan biaya operasional',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      OperatingCostModel operatingCost = OperatingCostModel(
          createdAt: DateTime.now(),
          storeId: authService.account.value!.storeId,
          name: operatingCostNameTextC.text,
          amount: int.parse(operatingCostAmountTextC.text.replaceAll('.', '')),
          note: operatingCostNoteTextC.text);
      await operatingCostServices.insert(operatingCost);
      Get.back();
      return Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Biaya operasional berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () {
            controller.rangePickerHandle(controller.selectedDate.value);
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    } catch (e) {
      Get.back();
      Get.defaultDialog(
        title: 'Gagal menambahkan biaya operasional',
        middleText: e.toString(),
      );
    }
  }

  void saveOperatingCost() {
    if (operatingCostNameTextC.text != '' &&
        operatingCostAmountTextC.text != '') {
      process();
    }
  }

  Get.defaultDialog(
    title: 'Tambah Biaya Operasional',
    content: SizedBox(
      height: 100,
      width: 350,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: operatingCostNameTextC,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Nama Biaya',
                      labelStyle: Get.context!.textTheme.bodySmall!
                          .copyWith(fontStyle: FontStyle.italic),
                      counterText: '',
                      filled: true,
                      fillColor: Theme.of(Get.context!)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      contentPadding: const EdgeInsets.all(10),
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const Text('  :   '),
                Expanded(
                  child: TextFormField(
                    controller: operatingCostAmountTextC,
                    textAlign: TextAlign.center,
                    maxLength: 15,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Biaya',
                      labelStyle: Get.context!.textTheme.bodySmall!
                          .copyWith(fontStyle: FontStyle.italic),
                      prefixText: 'Rp',
                      counterText: '',
                      filled: true,
                      fillColor: Theme.of(Get.context!)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      contentPadding: const EdgeInsets.all(10),
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        String newValue = currency
                            .format(int.parse(value.replaceAll('.', '')));

                        if (newValue != operatingCostAmountTextC.text) {
                          operatingCostAmountTextC.value = TextEditingValue(
                            text: newValue,
                            selection: TextSelection.collapsed(
                                offset: newValue.length),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextFormField(
                controller: operatingCostNoteTextC,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  labelStyle: Get.context!.textTheme.bodySmall!
                      .copyWith(fontStyle: FontStyle.italic),
                  counterText: '',
                  filled: true,
                  fillColor: Theme.of(Get.context!)
                      .colorScheme
                      .secondary
                      .withOpacity(0.2),
                  contentPadding: const EdgeInsets.all(10),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  isDense: true,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ),
    ),
    confirm: ElevatedButton(
      onPressed: () => saveOperatingCost(),
      child: const Text(
        'Simpan Biaya Operasional',
      ),
    ),
  );
}
