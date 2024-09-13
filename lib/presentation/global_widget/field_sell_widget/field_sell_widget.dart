import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/utils/display_format.dart';

class SellTextfield extends StatelessWidget {
  const SellTextfield({
    super.key,
    required this.title,
    required this.asignNumber,
    required this.onChanged,
  });

  final String title;
  final RxDouble asignNumber;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final textC = TextEditingController();
      textC.text = currency.format(asignNumber.value);
      textC.selection = TextSelection.fromPosition(
        TextPosition(offset: textC.text.length),
      );

      return TextField(
          controller: textC,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: title,
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
              if (newValue != textC.text) {
                textC.value = TextEditingValue(
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
