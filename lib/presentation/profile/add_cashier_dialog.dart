import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/account_model.dart';
import '../../infrastructure/models/user_model.dart';
import '../global_widget/popup_page_widget.dart';
import 'controllers/profile.controller.dart';

void addCashierDialog() {
  final ProfileController controller = Get.find();

  showPopupPageWidget(
    title: 'Tambah Kasir',
    height: MediaQuery.of(Get.context!).size.height * (0.4),
    width: MediaQuery.of(Get.context!).size.width * (0.9),
    content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text('ajdhawkodhawoiud'),
          Form(
            key: controller.formCashierKey,
            child: Column(
              children: [
                // Text('Tambah Kasir',
                //     style: Get.context!.textTheme.titleLarge),
                // const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  height: 50,
                  child: TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, labelText: 'Nama Kasir'),
                    validator: (value) =>
                        controller.validateCashierName(value),
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  height: 50,
                  child: TextFormField(
                    controller: controller.passwordController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, labelText: 'PIN'),
                    obscureText: true,
                    validator: (value) => controller.validatePassword(value),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 16.0),
          // ElevatedButton(
          //   onPressed: () {
          //     controller.registerWorker();
          //     Get.back();
          //   },
          //   child: const Text('Tambah Kasir'),
          // ),
        ],
      ),
    ),
    buttonList: [
      ElevatedButton(
        onPressed: () => controller.registerWorker(),
        child: const Text('Tambah Kasir'),
      ),
    ],
  );
}

class CheckBoxWidget extends StatelessWidget {
  const CheckBoxWidget({
    super.key,
    required this.title,
    required this.cashier,
    required this.accessName,
  });

  final String title;
  final Cashier cashier;
  final String accessName;

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Obx(
      () => InkWell(
        onTap: () => controller.checkBoxHandle(cashier, accessName),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          margin: const EdgeInsets.all(4),
          child: Row(
            children: [
              Checkbox(
                value: cashier.accessList.contains(accessName),
                onChanged: (_) =>
                    controller.checkBoxHandle(cashier, accessName),
              ),
              Text(
                title,
                style: cashier.accessList.contains(accessName)
                    ? context.textTheme.bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.primary)
                    : context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
