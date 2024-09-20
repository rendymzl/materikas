import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/profile.controller.dart';

class AddCashierWidget extends StatelessWidget {
  const AddCashierWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Form(
            key: controller.formCashierKey,
            child: Column(
              children: [
                Text('Tambah Kasir', style: context.textTheme.titleLarge),
                const SizedBox(height: 12),
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
                    validator: (value) => controller.validateCashierName(value),
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
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => controller.registerWorker(),
            child: const Text('Tambah Kasir'),
          ),
        ],
      ),
    );
  }
}
