import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/utils/display_format.dart';
// import '../../../infrastructure/utils/display_format.dart';

class QuantityTextField extends StatelessWidget {
  const QuantityTextField({
    super.key,
    required this.item,
    required this.onChanged,
    this.isReturn = false,
    this.title = 'Jumlah',
  });

  final CartItem item;
  final Function(String) onChanged;
  final bool isReturn;
  final String? title;

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
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          labelText: ' $title',
          labelStyle: context.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic),
          prefix: vertical
              ? IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24, // Lebar minimum
                    minHeight: 24, // Tinggi minimum
                  ),
                  onPressed: () =>
                      onChanged((qty - 1).clamp(0, qty).toString()),
                  icon: const Icon(Icons.remove),
                  iconSize: 16,
                )
              : Text('x'),
          counterText: '',
          suffix: vertical
              ? IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24, // Lebar minimum
                    minHeight: 24, // Tinggi minimum
                  ),
                  onPressed: () => onChanged((qty + 1).toString()),
                  icon: const Icon(Icons.add),
                  iconSize: 16,
                )
              : Text(item.product.unit),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          contentPadding: !vertical ? null : const EdgeInsets.all(0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.grey)),
          // border: const OutlineInputBorder(),
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
