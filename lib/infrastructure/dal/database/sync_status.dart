import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:materikas/infrastructure/dal/database/powersync.dart';
import 'package:powersync/powersync.dart';

import '../../../presentation/global_widget/app_dialog_widget.dart';
import '../../../presentation/splash/controllers/splash.controller.dart';

class SyncAppBar extends GetxController {
  Rx<SyncStatus> connectionState = db.currentStatus.obs;
  late StreamSubscription<SyncStatus> _syncStatusSubscription;

  @override
  void onInit() {
    super.onInit();
    _syncStatusSubscription = db.statusStream.listen((event) {
      connectionState.value = db.currentStatus;
    });
  }

  @override
  void onClose() {
    _syncStatusSubscription.cancel();
    super.onClose();
  }
}

class StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final SyncAppBar syncController = Get.find();
  final SplashController controller = Get.find();

  StatusAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: Obx(() {
        return _getStatusIcon(syncController.connectionState.value);
      }),
      actions: <Widget>[
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
        // IconButton(
        //   onPressed: () => controller.checkStats(),
        //   icon: const Icon(Symbols.logout),
        // ),
      ],
    );
  }

  Widget _getStatusIcon(SyncStatus status) {
    if (status.anyError != null) {
      if (!status.connected) {
        return _makeIcon(status.anyError!.toString(), Icons.cloud_off);
      } else {
        return _makeIcon(status.anyError!.toString(), Icons.sync_problem);
      }
    } else if (status.connecting) {
      // Timer.run(() {
      //   syncController.hasSynced.value = true;
      // });
      return _makeIcon('Connecting', Icons.cloud_sync_outlined);
    } else if (!status.connected) {
      return _makeIcon('Not connected', Icons.cloud_off);
    } else if (status.uploading && status.downloading) {
      return _makeIcon('Uploading and downloading', Icons.cloud_sync_outlined);
    } else if (status.uploading) {
      return _makeIcon('Uploading', Icons.cloud_sync_outlined);
    } else if (status.downloading) {
      // if (status.lastSyncedAt != null) {
      //   Timer.run(() {
      //     syncController.hasSynced.value = true;
      //   });
      // }
      return _makeIcon('Downloading', Icons.cloud_sync_outlined);
    } else {
      return _makeIcon('Connected', Icons.cloud_queue);
    }
  }

  Widget _makeIcon(String tooltip, IconData icon) {
    return Tooltip(
      message: tooltip,
      child: Icon(icon),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
