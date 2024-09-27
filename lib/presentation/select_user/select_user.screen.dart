import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../global_widget/app_dialog_widget.dart';
import 'controllers/select_user.controller.dart';

class SelectUserScreen extends GetView<SelectUserController> {
  const SelectUserScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            controller.isConnected.value
                ? AppDialog.show(
                    title: 'Keluar',
                    content: 'Keluar dari aplikasi?',
                    confirmText: "Ya",
                    cancelText: "Tidak",
                    confirmColor: Colors.grey,
                    cancelColor: Get.theme.primaryColor,
                    onConfirm: () => controller.signOut(),
                    onCancel: () => Get.back(),
                  )
                : await Get.defaultDialog(
                    title: 'Error',
                    middleText:
                        'Tidak ada koneksi internet untuk mengeluarkan akun.',
                    confirm: TextButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      child: const Text('OK'),
                    ),
                  );
          },
          icon: const Icon(Symbols.logout),
        ),
      ),
      body: Obx(
        () => Center(
          child: controller.isLoading.value
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    // const SizedBox(height: 8),
                    // Text(controller.loadingStatus.value)
                  ],
                )
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  width: 400,
                  height: 550,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pilih Akun',
                                  style: context.textTheme.titleLarge),
                              IconButton(
                                onPressed: () async {
                                  controller.isConnected.value
                                      ? AppDialog.show(
                                          title: 'Keluar',
                                          content: 'Keluar dari aplikasi?',
                                          confirmText: "Ya",
                                          cancelText: "Tidak",
                                          confirmColor: Colors.grey,
                                          cancelColor: Get.theme.primaryColor,
                                          onConfirm: () => controller.signOut(),
                                          onCancel: () => Get.back(),
                                        )
                                      : await Get.defaultDialog(
                                          title: 'Error',
                                          middleText:
                                              'Tidak ada koneksi internet untuk mengeluarkan akun.',
                                          confirm: TextButton(
                                            onPressed: () {
                                              Get.back();
                                              Get.back();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        );
                                },
                                icon: const Icon(Symbols.logout),
                              ),
                            ],
                          ),
                          // Obx(() {
                          //   return Text('${controller.account.value?.id}');
                          // }),
                          // const SizedBox(height: 16),
                          // Divider(color: Colors.grey[200]),
                          const SizedBox(height: 16),
                          Obx(
                            () => ListTile(
                              leading: const Icon(Symbols.person_pin, fill: 1),
                              trailing:
                                  const Icon(Symbols.chevron_right, fill: 1),
                              selectedTileColor:
                                  Theme.of(context).colorScheme.primary,
                              selectedColor: Colors.white,
                              selected:
                                  controller.selectedUser.value == 'owner',
                              title: const Text(
                                'Pemilik Toko',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () => controller.selectUser('owner'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[200]),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SizedBox(
                              // height: 250,
                              child: ListView.builder(
                                itemCount:
                                    controller.account.value!.users.length,
                                itemBuilder: (context, index) {
                                  final cashier =
                                      controller.account.value!.users[index];
                                  return Obx(
                                    () => ListTile(
                                      leading: const Icon(Symbols.person_filled,
                                          fill: 1),
                                      trailing: const Icon(
                                          Symbols.chevron_right,
                                          fill: 1),
                                      selectedTileColor:
                                          Theme.of(context).colorScheme.primary,
                                      selectedColor: Colors.white,
                                      selected: controller.selectedUser.value ==
                                          cashier.name,
                                      title: Text(
                                        cashier.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      onTap: () =>
                                          controller.selectUser(cashier.name),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input untuk password
                          TextFormField(
                            controller: controller.passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'PIN',
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tombol login
                          ElevatedButton(
                            onPressed: () => controller.loginUserHandle(),
                            child: const Text('Pilih Akun'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
