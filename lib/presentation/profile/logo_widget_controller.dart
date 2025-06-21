import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'package:get/get.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

import '../../../infrastructure/dal/database/powersync_attachment.dart';
import '../../infrastructure/models/store_model.dart';

class LogoWidgetController extends GetxController {
  final StoreModel store;
  var photoPath = ''.obs;
  var fileExists = false.obs;
  var attachment = Rxn<Attachment>();

  LogoWidgetController(this.store);

  @override
  void onInit() async {
    super.onInit();
    store.logoUrl ??= RxString('');
    print('LogoWidgetController init ${store.logoUrl?.value}');

    await _getPhotoState(store.logoUrl!.value);
    // ever(store.logoUrl!, _getPhotoState);
  }

  Future<void> _getPhotoState(String? photoId) async {
    if (photoId == null || photoId.isEmpty) {
      photoPath.value = '';
      fileExists.value = false;
      return;
    }

    print('LogoWidgetController _getPhotoState photoId $photoId');

    // String localUri = attachmentQueue.getLocalFilePathSuffix('$photoId.jpg');
    String localUri = await attachmentQueue.getLocalUri('$photoId.jpg');
    print('LogoWidgetController _getPhotoState photoId $localUri');
    // print('LogoWidgetController _getPhotoState photoId $localUri1');
    photoPath.value = localUri;
    fileExists.value = await File(localUri).exists();

    final row = await attachmentQueue.db
        .getOptional('SELECT * FROM attachments_queue WHERE id = ?', [photoId]);
    if (row != null) {
      attachment.value = Attachment.fromRow(row);
    } else {
      attachment.value = null;
    }
    print('LogoWidgetController ${attachment.value}');
  }

  /// Fungsi untuk mengambil ByteData dari photoPath
  // Future<ByteData?> getPhotoByteData() async {
  //   if (photoPath.value.isEmpty || !fileExists.value) {
  //     return null;
  //   }

  //   try {
  //     File imageFile = File(photoPath.value);
  //     Uint8List bytes = await imageFile.readAsBytes();
  //     return bytes.buffer.asByteData();
  //   } catch (e) {
  //     print("Error converting file to ByteData: $e");
  //     return null;
  //   }
  // }
}
