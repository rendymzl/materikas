import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class DiscountTextfield extends StatelessWidget {
  const DiscountTextfield({
    super.key,
    required this.item,
    required this.onChanged,
  });

  final CartItem item;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final discountTextC = TextEditingController();
      discountTextC.text = currency.format(item.individualDiscount.value);
      discountTextC.selection = TextSelection.fromPosition(
        TextPosition(offset: discountTextC.text.length),
      );

      return TextField(
          controller: discountTextC,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'Diskon',
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
              if (newValue != discountTextC.text) {
                discountTextC.value = TextEditingValue(
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
