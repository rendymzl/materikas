import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

import '../../infrastructure/models/store_model.dart';
import 'logo_widget_controller.dart';

class LogoWidget extends GetView {
  final StoreModel store;
  final File? imgFile;

  const LogoWidget({super.key, required this.store, this.imgFile});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(LogoWidgetController(store), tag: '${store.id}1');

    return Obx(() {
      if (controller.attachment.value?.state ==
          AttachmentState.archived.index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Unavailable"),
            const SizedBox(height: 8),
          ],
        );
      }

      if (!controller.fileExists.value) {
        return Text(controller.photoPath.value);
        // return const Text("Downloading...");
      }

      print('path aaa ${controller.photoPath.value}');
      File imageFile = File(controller.photoPath.value);
      int lastModified = imageFile.existsSync()
          ? imageFile.lastModifiedSync().millisecondsSinceEpoch
          : 0;
      Key key = ObjectKey('${controller.photoPath.value}:$lastModified');

      return Image.file(
        key: key,
        imgFile ?? imageFile,
        width: 50,
        height: 50,
      );
    });
  }
}
