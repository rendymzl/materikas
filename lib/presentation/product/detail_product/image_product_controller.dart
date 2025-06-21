import 'dart:io';
import 'package:get/get.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

import '../../../infrastructure/dal/database/powersync_attachment.dart';
import '../../../infrastructure/models/product_model.dart';

class ImageProductController extends GetxController {
  final ProductModel product;
  var photoPath = ''.obs;
  var fileExists = false.obs;
  var attachment = Rxn<Attachment>();
  var loading = true.obs;

  ImageProductController(this.product);

  @override
  void onInit() {
    super.onInit();
    resolvePhotoState();
    if (product.imageUrl != null) {
      ever(fileExists, (_) => resolvePhotoState());
    }
  }

  Future<void> resolvePhotoState() async {
    loading.value = true;

    final photoId = product.imageUrl?.value;
    print('debugPhoto photoId: $photoId');
    if (photoId == null) {
      photoPath.value = '';
      fileExists.value = false;
      attachment.value = null;
      loading.value = false;
      return;
    }

    final path = await attachmentQueue.getLocalUri('$photoId.jpg');
    print('debugPhoto path: $path');
    photoPath.value = path;

    fileExists.value = await File(path).exists();

    final row = await attachmentQueue.db
        .getOptional('SELECT * FROM attachments_queue WHERE id = ?', [photoId]);

    if (row != null) {
      attachment.value = Attachment.fromRow(row);
    }

    loading.value = false;
  }

  // Future<resolvedPhotoState> _getPhotoState(String? photoId) async {
  //   if (photoId == null || photoId.isEmpty) {
  //     return resolvedPhotoState(photoPath: null, fileExists: false);
  //   }
  //   photoPath.value = await attachmentQueue.getLocalUri('$photoId.jpg');

  //   bool fileExists = await File(photoPath.value).exists();

  //   final row = await attachmentQueue.db
  //       .getOptional('SELECT * FROM attachments_queue WHERE id = ?', [photoId]);

  //   if (row != null) {
  //     Attachment attachment = Attachment.fromRow(row);
  //     return resolvedPhotoState(
  //       photoPath: photoPath.value,
  //       fileExists: fileExists,
  //       attachment: attachment,
  //     );
  //   }

  //   return resolvedPhotoState(
  //       photoPath: photoPath.value, fileExists: fileExists, attachment: null);
  // }

  // Future<void> _getPhotoState(String? photoId) async {
  //   print('debugPhoto photoId: $photoId');
  //   if (photoId == null || photoId.isEmpty) {
  //     photoPath.value = '';
  //     fileExists.value = false;
  //     return;
  //   }

  //   String localUri = await attachmentQueue.getLocalUri('$photoId.jpg');
  //   photoPath.value = localUri;
  //   print('debugPhoto localUri: $localUri');
  //   fileExists.value = await File(localUri).exists();

  //   final row = await attachmentQueue.db
  //       .getOptional('SELECT * FROM attachments_queue WHERE id = ?', [photoId]);
  //   print('debugPhoto row attachmentQueue: $row');
  //   if (row != null) {
  //     attachment.value = Attachment.fromRow(row);
  //   } else {
  //     attachment.value = null;
  //   }
  //   print('debugPhoto attachment.value: ${attachment.value}');
  // }
}
