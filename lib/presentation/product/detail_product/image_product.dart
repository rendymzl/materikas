import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

import '../../../infrastructure/models/product_model.dart';
import 'image_product_controller.dart';

class ImageProductWidget extends GetView {
  final ProductModel product;

  const ImageProductWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(ImageProductController(product), tag: product.id);

    return Obx(() {
      final filePath = controller.photoPath.value;
      final fileArchived =
          controller.attachment.value?.state == AttachmentState.archived.index;

      if (product.imageUrl != null && product.imageUrl!.value.isNotEmpty) {
        controller.resolvePhotoState();
      }
      if (fileArchived) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Unavailable"),
            const SizedBox(height: 8),
          ],
        );
      }

      if (!(controller.fileExists.value)) {
        return const Text("Downloading...");
      }

      final file = File(filePath);
      int lastModified = file.existsSync()
          ? file.lastModifiedSync().millisecondsSinceEpoch
          : 0;
      Key key = ObjectKey('$filePath:$lastModified');

      return Image.file(
        key: key,
        file,
        width: 50,
        height: 50,
      );
    });
  }
}
