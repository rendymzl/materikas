import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../global_widget/app_dialog_widget.dart';
import 'controllers/select_user.controller.dart';

class SelectUserScreen extends GetView<SelectUserController> {
  const SelectUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Obx(() => Center(
              child: controller.isLoading.value
                  ? const _LoadingIndicator()
                  : _SelectUserForm(controller: controller),
            )),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [CircularProgressIndicator()],
    );
  }
}

class _SelectUserForm extends StatelessWidget {
  final SelectUserController controller;

  const _SelectUserForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 400,
        height: 550,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AppBar(controller: controller),
                const SizedBox(height: 16),
                _OwnerListTile(controller: controller),
                const SizedBox(height: 16),
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                _CashierList(controller: controller),
                const SizedBox(height: 16),
                _PinField(controller: controller),
                const SizedBox(height: 24),
                _LoginButton(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _AppBar extends StatelessWidget {
  final SelectUserController controller;

  const _AppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Pilih Akun', style: context.textTheme.titleLarge),
        IconButton(
          onPressed: () async {
            AppDialog.show(
              title: 'Keluar',
              content: 'Keluar dari aplikasi?',
              confirmText: "Ya",
              cancelText: "Tidak",
              confirmColor: Colors.grey,
              cancelColor: Get.theme.primaryColor,
              onConfirm: () => controller.signOut(),
              onCancel: () => Get.back(),
            );
          },
          icon: const Icon(Symbols.logout),
        ),
      ],
    );
  }
}

class _OwnerListTile extends StatelessWidget {
  final SelectUserController controller;

  const _OwnerListTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => ListTile(
        leading: const Icon(Symbols.person_pin, fill: 1),
        trailing: const Icon(Symbols.chevron_right, fill: 1),
        selectedTileColor: Theme.of(context).colorScheme.primary,
        selectedColor: Colors.white,
        selected: controller.selectedUserString.value == 'owner',
        title: const Text(
          'Pemilik Toko',
          style: TextStyle(fontSize: 16),
        ),
        onTap: () => controller.selectUserString('owner'),
      ),
    );
  }
}

class _CashierList extends StatelessWidget {
  final SelectUserController controller;

  const _CashierList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.account.value?.users.length ?? 0,
          itemBuilder: (context, index) {
            final cashier = controller.account.value!.users[index];
            return Obx(
                  () => ListTile(
                leading: const Icon(Symbols.person_filled, fill: 1),
                trailing: const Icon(Symbols.chevron_right, fill: 1),
                selectedTileColor: Theme.of(context).colorScheme.primary,
                selectedColor: Colors.white,
                selected: controller.selectedUserString.value == cashier.name,
                title: Text(
                  cashier.name,
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () => controller.selectUserString(cashier.name),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  final SelectUserController controller;

  const _PinField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'PIN',
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final SelectUserController controller;

  const _LoginButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => controller.loginUserHandle(),
      child: const Text('Pilih Akun'),
    );
  }
}
