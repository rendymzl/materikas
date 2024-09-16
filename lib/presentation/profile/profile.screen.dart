import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/profile.controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MenuWidget(title: 'Profile'),
          Expanded(
            flex: 3,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (5 / 8),
              child: const Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Card(child: ProfileStoreWidget()),
                  ),
                  Expanded(
                    flex: 3,
                    child: Card(child: AddCashierWidget()),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (5 / 8),
              child: Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Daftar Kasir',
                          style: context.textTheme.titleLarge,
                        ),
                        Divider(color: Colors.grey[200]),
                        Obx(
                          () {
                            return controller.account.value!.users.isEmpty
                                ? const Text('Tidak ada kasir')
                                : Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: controller
                                          .account.value!.users.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: Text((index + 1).toString()),
                                          title: Text(controller.account.value!
                                              .users[index].name),
                                        );
                                      },
                                    ),
                                  );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddCashierWidget extends StatelessWidget {
  const AddCashierWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Expanded(
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
                          border: InputBorder.none, labelText: 'Password'),
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
      ),
    );
  }
}

class ProfileStoreWidget extends StatelessWidget {
  const ProfileStoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.find();
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                        onPressed: () {},
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
                      const Text('Nama Toko'),
                      SizedBox(
                        width: 200,
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
                      const Text('Alamat'),
                      SizedBox(
                        width: 200,
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
                      const Text('No Hp'),
                      SizedBox(
                        width: 200,
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
                      const Text('No Telp'),
                      SizedBox(
                        width: 200,
                        child: Text(
                          controller.store.value!.telp.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
