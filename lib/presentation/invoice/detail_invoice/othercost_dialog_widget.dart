import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/popup_page_widget.dart';

void otherCostDialogWidget(InvoiceModel invoice) {
  late InvoiceService _invoiceService = Get.find();
  final otherCostNameTextC = TextEditingController();
  final otherCostAmountTextC = TextEditingController();

  Future<void> process(InvoiceModel invoice) async {
    Get.defaultDialog(
      title: 'Menambahkan biaya lainnya',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      invoice.addOtherCost(otherCostNameTextC.text,
          double.parse(otherCostAmountTextC.text.replaceAll('.', '')));

      await _invoiceService.update(invoice);
      Get.back();

      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Biaya lainnya berhasil disimpan.',
      );
      invoice.updateIsDebtPaid();
      invoice.updateReturn();
      Get.back();
    } catch (e) {
      Get.back();
      Get.defaultDialog(
        title: 'Gagal menambahkan biaya lainnya',
        middleText: e.toString(),
        barrierDismissible: false,
      );
    }
  }

  showPopupPageWidget(
    title: 'Tambah Biaya Lainnya',
    height: 150,
    width: 450,
    content: Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: otherCostNameTextC,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Nama Biaya',
              labelStyle: Get.context!.textTheme.bodySmall!
                  .copyWith(fontStyle: FontStyle.italic),
              counterText: '',
              filled: true,
              fillColor:
                  Theme.of(Get.context!).colorScheme.secondary.withOpacity(0.2),
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              isDense: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == '') {
                return 'Kode tidak boleh kosong';
              } else {
                return null;
              }
            },
          ),
        ),
        const Text('  :   '),
        Expanded(
          child: TextFormField(
            controller: otherCostAmountTextC,
            textAlign: TextAlign.center,
            maxLength: 15,
            decoration: InputDecoration(
              labelText: 'Jumlah Biaya',
              labelStyle: Get.context!.textTheme.bodySmall!
                  .copyWith(fontStyle: FontStyle.italic),
              prefixText: 'Rp',
              counterText: '',
              filled: true,
              fillColor:
                  Theme.of(Get.context!).colorScheme.secondary.withOpacity(0.2),
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              isDense: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                String newValue =
                    currency.format(int.parse(value.replaceAll('.', '')));

                if (newValue != otherCostAmountTextC.text) {
                  otherCostAmountTextC.value = TextEditingValue(
                    text: newValue,
                    selection: TextSelection.collapsed(offset: newValue.length),
                  );
                }
              }
            },
          ),
        ),
      ],
    ),
    buttonList: [
      Row(
        children: [
          SizedBox(
            width: 150,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                if (otherCostNameTextC.text != '' &&
                    otherCostAmountTextC.text != '') {
                  process(invoice);
                }
              },
              child: const Text('Tambah Biaya'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
