import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/menu_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../app_dialog_widget.dart';
import 'menu_controller.dart';

class MenuWidget extends GetView<MenuWidgetController> {
  const MenuWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border(
        //   bottom: BorderSide(color: Colors.blueGrey[100]!, width: 1),
        // ),
      ),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items
          children: [
            Expanded(
              // Allow menu items to expand
              child: Obx(
                () {
                  var data = controller.menuData;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    itemBuilder: (context, index) =>
                        buildMenuEntry(data[index], index, context),
                  );
                },
              ),
            ),
            Row(
              // Group status indicator and logout button
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 8), // Add margin
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Make it circular
                      color: controller.internetService.isConnected.value
                          ? Colors.green
                          : Colors.red,
                    ),
                    height: 16,
                    width: 16,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    AppDialog.show(
                      title: 'Keluar',
                      content: 'Ganti Pengguna?',
                      confirmText: "Ya",
                      cancelText: "Tidak",
                      confirmColor: Colors.grey,
                      cancelColor: Get.theme.primaryColor,
                      onConfirm: () => controller.changeUser(),
                      onCancel: () => Get.back(),
                    );
                  },
                  icon: const Icon(Symbols.logout),
                  iconSize: 24, // Increase icon size for better visibility
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuEntry(MenuModel data, int index, BuildContext context) {
    return Obx(
      () => MouseRegion(
        onEnter: (_) => controller.hoveredIndex.value = index,
        onExit: (_) => controller.hoveredIndex.value = -1,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: controller.selectedIndexMenu.value == index
                    ? Get.theme.primaryColor
                    : (controller.hoveredIndex.value == index
                        ? Colors.grey
                        : Colors.transparent),
                width: 2,
              ),
            ),
          ),
          child: TextButton(
            onPressed: () => controller.handleClick(index, data.label),
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              foregroundColor: WidgetStatePropertyAll<Color>(
                  controller.selectedIndexMenu.value == index
                      ? Get.theme.primaryColor
                      : Colors.grey[700]!),
              textStyle: const WidgetStatePropertyAll<TextStyle>(
                  TextStyle(fontSize: 14)),
              overlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(data.icon, fill: 1),
                const SizedBox(width: 4),
                Text(data.label, style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildDrawer(BuildContext context) {
  final controller = Get.find<MenuWidgetController>();
  return Drawer(
    child: Obx(
      () => ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              controller.isOwner.value
                  ? controller.authService.account.value!.name
                  : controller.authService.selectedUser.value?.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text(''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Image(
                  image:
                      AssetImage('assets/icon/logo-materikas-transparent.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          ...controller.menuData.map((menu) {
            int index = controller.menuData.indexOf(menu);
            return ListTile(
              tileColor: controller.selectedIndexMenu.value == index
                  ? Get.theme.primaryColor
                  : null,
              leading: Icon(
                menu.icon,
                color: controller.selectedIndexMenu.value == index
                    ? Colors.white
                    : null,
              ),
              title: Text(
                menu.label,
                style: TextStyle(
                  color: controller.selectedIndexMenu.value == index
                      ? Colors.white
                      : null,
                ),
              ),
              onTap: controller.selectedIndexMenu.value == index
                  ? () => Get.back()
                  : () {
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        controller.handleClick(index, menu.label);
                      });
                    },
            );
          }),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Symbols.logout),
            title: const Text('Keluar'),
            onTap: () async {
              AppDialog.show(
                title: 'Keluar',
                content: 'Ganti Pengguna?',
                confirmText: "Ya",
                cancelText: "Tidak",
                confirmColor: Colors.grey,
                cancelColor: Get.theme.primaryColor,
                onConfirm: () => controller.changeUser(),
                onCancel: () => Get.back(),
              );
            },
          ),
        ],
      ),
    ),
  );
}
