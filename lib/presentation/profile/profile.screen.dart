import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'add_cashier.dart';
import 'add_cashier_dialog.dart';
import 'cashier_list.dart';
import 'cashier_list_mobile.dart';
import 'controllers/profile.controller.dart';
import 'profile_store_widget.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      // backgroundColor: isMobile ? Colors.white : null,
      appBar: isMobile
          ? AppBar(
              title: Text(controller.store.value!.name.value),
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              // actions: [
              //   IconButton(
              //     onPressed: () => detailStore(
              //         foundStore: controller.store.value, isMobile: isMobile),
              //     icon: Icon(
              //       Symbols.edit_square,
              //       // color: Theme.of(context).colorScheme.primary,
              //     ),
              //   ),
              // ],
            )
          : null,
      drawer: isMobile ? buildDrawer(context) : null,
      body: Column(
        children: [
          if (!isMobile) MenuWidget(title: 'Toko'),
          Expanded(
            child: isMobile
                ? buildMobileLayout(context)
                : buildDesktopLayout(context),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk tampilan desktop
  Widget buildDesktopLayout(BuildContext context) {
    // controller.isMobile.value = false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  // flex: 3,
                  child: Card(
                    elevation: 0,
                    child: ProfileStoreWidget(),
                  ),
                ),
                Expanded(
                  // flex: 2,
                  child: Card(
                    elevation: 0,
                    child: AddCashierWidget(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Card(
              elevation: 0,
              child: CashierListWidget(),
            ),
          )
        ],
      ),
    );
  }

  // Fungsi untuk tampilan mobile
// Fungsi untuk tampilan mobile
  Widget buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(child: ProfileStoreWidget()),
          // Divider(color: Colors.grey[200]),
          const SizedBox(height: 16.0),
          Expanded(
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CashierListMobile(),
            )),
          ),
          // AddCashierWidget(),

          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => addCashierDialog(),
                  child: const Text('Tambah Kasir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
