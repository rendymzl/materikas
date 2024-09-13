import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';

class QuantityTextField extends StatelessWidget {
  const QuantityTextField({
    super.key,
    required this.item,
    required this.onChanged,
    this.isReturn = false,
  });

  final CartItem item;
  final Function(String) onChanged;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qtyTextC = TextEditingController();
      var qty = isReturn ? item.quantityReturn.value : item.quantity.value;
      String displayValue = qty % 1 == 0
          ? qty.toInt().toString()
          : qty.toString().replaceAll('.', ',');
      qtyTextC.text = displayValue;
      qtyTextC.selection = TextSelection.fromPosition(
        TextPosition(offset: qtyTextC.text.length),
      );
      return TextField(
        controller: qtyTextC,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Jumlah',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
          prefixText: 'x',
          counterText: '',
          suffixText: item.product.unit,
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          contentPadding: const EdgeInsets.all(10),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d*'))
        ],
        onChanged: (value) {
          if (!value.endsWith(',')) {
            value == '' ? 0 : value;
            String unformattedValue = value.replaceAll('.', '');
            String processedValue = unformattedValue.replaceAll(',', '.');
            print('QuantityTextField $processedValue');
            onChanged(processedValue);
          }
        },
      );
    });
  }
}
