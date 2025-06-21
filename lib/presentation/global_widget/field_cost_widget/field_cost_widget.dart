import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class CostTextfield extends StatelessWidget {
  const CostTextfield({
    super.key,
    required this.item,
    required this.onChanged,
  });

  final CartItem item;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final costTextC = TextEditingController();
      costTextC.text = currency.format(item.product.costPrice.value);
      costTextC.selection = TextSelection.fromPosition(
        TextPosition(offset: costTextC.text.length),
      );

      String? validator(String value) {
        var isErr =
            ((value.isEmpty ? 0 : double.parse(value.replaceAll('.', ''))) >
                    item.product.sellPrice1.value) &&
                (item.product.sellPrice1.value != 0);
        return isErr ? 'Harga modal harus lebih rendah dari harga jual.' : null;
      }

      return TextFormField(
          autovalidateMode: AutovalidateMode.always,
          validator: (value) => validator(value!),
          controller: costTextC,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'Harga Beli',
            labelStyle: Get.context!.textTheme.bodySmall!
                .copyWith(fontStyle: FontStyle.italic),
            prefixText: 'Rp ',
            counterText: '',
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            contentPadding: const EdgeInsets.all(10),
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
                  currency.format(double.parse(value.replaceAll('.', '')));
              if (newValue != costTextC.text) {
                costTextC.value = TextEditingValue(
                  text: newValue,
                  selection: TextSelection.collapsed(offset: newValue.length),
                );
              }
            }
            onChanged(value);
          });
    });
  }
}
