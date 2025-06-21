import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'controllers/pin_controller.dart';

class ChangePinWidget extends StatelessWidget {
  const ChangePinWidget({super.key, this.setup = false});
  final bool setup;

  @override
  Widget build(BuildContext context) {
    // ProfileController controller = Get.put(ProfileController());
    final controller = Get.find<PinController>();
    controller.oldPinController.text = '';
    controller.newPinController.text = '';
    const outlineRed =
        OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Form(
            key: controller.formkey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                if (!setup)
                  Obx(
                    () => TextFormField(
                      controller: controller.oldPinController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'PIN Sekarang',
                        prefixIcon: const Icon(Symbols.lock, fill: 1),
                        suffixIcon: IconButton(
                          icon: const Icon(Symbols.remove_red_eye, fill: 1),
                          onPressed: () =>
                              controller.toggleHidePassword('oldPin'),
                        ),
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(Get.context!).colorScheme.primary),
                        focusedErrorBorder: outlineRed,
                        errorBorder: outlineRed,
                      ),
                      obscureText: controller.hideOldPassword.value,
                      validator: (value) => controller.validateOldPin(value!),
                      onFieldSubmitted: (_) => controller.changePinHandle(),
                    ),
                  ),
                if (!setup) const SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    controller: controller.newPinController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: setup ? 'Masukkan PIN' : 'PIN Baru',
                      prefixIcon: const Icon(Symbols.lock, fill: 1),
                      suffixIcon: IconButton(
                        icon: const Icon(Symbols.remove_red_eye, fill: 1),
                        onPressed: () =>
                            controller.toggleHidePassword('newPin'),
                      ),
                      labelStyle: const TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(
                          color: Theme.of(Get.context!).colorScheme.primary),
                      focusedErrorBorder: outlineRed,
                      errorBorder: outlineRed,
                    ),
                    obscureText: controller.hideNewPassword.value,
                    validator: (value) => controller.validateNewPin(value!),
                    onFieldSubmitted: (_) => controller.changePinHandle(),
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
