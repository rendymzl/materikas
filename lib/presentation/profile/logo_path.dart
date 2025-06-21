// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

// import '../../infrastructure/models/store_model.dart';
// import 'logo_widget_controller.dart';

// class LogoPath extends GetView {
//   final StoreModel store;

//   const LogoPath({super.key, required this.store});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(LogoWidgetController(store), tag: store.id);

//     return Obx(() {
//       if (controller.attachment.value?.state ==
//           AttachmentState.archived.index) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("Unavailable"),
//             const SizedBox(height: 8),
//             // _buildTakePhotoButton(controller),
//           ],
//         );
//       }

//       if (!controller.fileExists.value) {
//         return const Text("Downloading...");
//       }

//       // if (product.id == null) {
//       //   return _buildTakePhotoButton(controller);
//       // }
//       print('path aaa ${controller.photoPath.value}');
//       File imageFile = File(controller.photoPath.value);
//       int lastModified = imageFile.existsSync()
//           ? imageFile.lastModifiedSync().millisecondsSinceEpoch
//           : 0;
//       Key key = ObjectKey('${controller.photoPath.value}:$lastModified');

//       return controller.photoPath.value
//     });
//   }

//   // Widget _buildTakePhotoButton(ImageProductController controller) {
//   //   return ElevatedButton(
//   //     onPressed: () async {
//   //       final camera = await setupCamera();
//   //       if (!Get.isSnackbarOpen) return;

//   //       if (camera == null) {
//   //         Get.snackbar(
//   //           'Error',
//   //           'No camera available',
//   //           backgroundColor: Colors.red,
//   //           colorText: Colors.white,
//   //         );
//   //         return;
//   //       }

//   //       Get.to(() => TakeLogoWidget(todoId: controller.todo.id, camera: camera));
//   //     },
//   //     child: const Text('Take Photo'),
//   //   );
//   // }
// }
