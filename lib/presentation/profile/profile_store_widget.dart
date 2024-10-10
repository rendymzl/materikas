import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/popup_page_widget.dart';
import 'controllers/profile.controller.dart';
import 'detail_profile_store.dart';

class ProfileStoreWidget extends StatelessWidget {
  const ProfileStoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.find();
    return Obx(() {
      var package = '';
      if (controller.account.value!.endDate != null) {
        package = date.format(controller.account.value!.endDate!);
      } else {
        package = 'Selamanya';
      }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Data Toko'),
                      IconButton(
                        onPressed: () =>
                            detailStore(foundStore: controller.store.value),
                        icon: Icon(
                          Symbols.edit_square,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 100, child: Text('Nama Toko')),
                      Expanded(
                        child: Text(
                          controller.store.value!.name.value,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 100, child: Text('Alamat')),
                      Expanded(
                        child: Text(
                          controller.store.value!.address.value,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 100, child: Text('No Hp')),
                      Expanded(
                        child: Text(
                          controller.store.value!.phone.value,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 100, child: Text('No Telp')),
                      Expanded(
                        child: Text(
                          controller.store.value!.telp.value,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 100, child: Text('Aktif sampai')),
                      Expanded(
                        child: Text(package),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => showPopupPageWidget(
                  title: 'Ubah PIN',
                  content: const ChangePinWidget(),
                  buttonList: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.changePinHandle(),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ]),
              child: const Text('Ubah PIN'),
            ),
          ],
        ),
      );
    });
  }
}

class ChangePinWidget extends StatelessWidget {
  const ChangePinWidget({super.key, this.setup = false});
  final bool setup;

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.put(ProfileController());
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
