import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/menu_model.dart';
import '../app_dialog_widget.dart';
import 'menu_controller.dart';

class MenuWidget extends GetView<MenuWidgetController> {
  const MenuWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    Get.put(MenuWidgetController(), permanent: true);

    return Container(
      // padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      height: 60,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Obx(
                  () {
                    var data = controller.menuData;
                    return ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: (data.length),
                      itemBuilder: (context, index) =>
                          buildMenuEntry(data[index], index, context),
                    );
                  },
                )
              ],
            ),
          ),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: controller.connected.value ? Colors.green : Colors.red,
              ),
              height: 12,
              width: 12,
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
              // controller.connected.value
              //     ? AppDialog.show(
              //         title: 'Keluar',
              //         content: 'Keluar dari aplikasi?',
              //         confirmText: "Ya",
              //         cancelText: "Tidak",
              //         confirmColor: Colors.grey,
              //         cancelColor: Get.theme.primaryColor,
              //         onConfirm: () => controller.signOut(),
              //         onCancel: () => Get.back(),
              //       )
              //     : await Get.defaultDialog(
              //         title: 'Error',
              //         middleText:
              //             'Tidak ada koneksi internet untuk mengeluarkan akun.',
              //         confirm: TextButton(
              //           onPressed: () {
              //             Get.back();
              //             Get.back();
              //           },
              //           child: const Text('OK'),
              //         ),
              //       );
            },
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(MenuModel data, int index, BuildContext context) {
    return Obx(
      () => ElevatedButton.icon(
        onPressed: () => controller.handleClick(index, data.label),
        icon: Icon(
          data.icon,
          color: controller.selectedIndex.value == index
              ? Colors.white
              : Colors.grey[700],
        ),
        label: Text(
          data.label,
          style: TextStyle(
            fontSize: 14,
            color: controller.selectedIndex.value == index
                ? Colors.white
                : Colors.grey[700],
            // fontWeight: controller.isExpand.value
            //     ? FontWeight.w600
            //     : FontWeight.normal,
          ),
        ),
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
          enableFeedback: true,
          backgroundColor: WidgetStatePropertyAll(
            controller.selectedIndex.value == index
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
