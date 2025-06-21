import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:materikas/infrastructure/models/account_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

import '../../../infrastructure/dal/database/powersync_attachment.dart';
import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/store_model.dart';
import '../../../infrastructure/models/user_model.dart';
// import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';
import 'package:powersync/powersync.dart' as powersync;

class ProfileController extends GetxController {
  final authService = Get.find<AuthService>();
  final accountService = Get.find<AccountService>();
  final storeService = Get.find<StoreService>();
  final InternetService internetService = Get.find();

  final setup = false.obs;

  late final account = authService.account;
  late final store = authService.store;
  late final cashiers = authService.cashiers;

  final formCashierKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  final CropController cropController = CropController();
  var selectedImage = Rx<File?>(null);
  var croppedImg = Rx<File?>(null);
  var displayImg = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  // late XFile image;

  Future<void> pickImage(BuildContext context) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        selectedImage.value = File(pickedImage.path);
        // image = pickedImage; // Assign pickedImage to image
        _showCropDialog();
      }
    } else {
      Get.snackbar("Izin ditolak", "Izinkan akses kamera.");
    }
  }

  void _showCropDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pangkas Gambar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Crop(
                    image: selectedImage.value!.readAsBytesSync(),
                    controller: cropController,
                    aspectRatio: 1, // 1:1 Ratio
                    onCropped: (result) async {
                      switch (result) {
                        case CropSuccess(:final croppedImage):
                          // image = XFile.fromData(croppedImage);
                          // final image = Image.memory(croppedImage);
                          croppedImg.value =
                              await saveXFileToFile(croppedImage);
                          // image = XFile(croppedImg.value!.path);
                          // print('photoSize ${image.path}');
                          Get.back(); // Tutup dialog setelah cropping selesai
                        case CropFailure(:final cause):
                          Get.snackbar(
                              'Error', 'Gagal memangkas gambar: $cause');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => cropController.crop(),
                child: const Text("Pangkas"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onInit() async {
    account.value = await accountService.get();
    setup.value = account.value!.accountType == 'setup';
    authService.getCashier();
    print('cashiers.length ${cashiers}');
    super.onInit();
  }

  String? validateCashierName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama kasir tidak boleh kosong';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN tidak boleh kosong';
    }
    return null;
  }

  Future<File> saveXFileToFile(Uint8List uint8ListFiles) async {
    // final bytes = await xfile.readAsBytes(); // Baca data dari XFile
    final tempDir = await getTemporaryDirectory();
    final file = File(
        "${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png");
    await file.writeAsBytes(uint8ListFiles);
    return file;
  }

  Future<String?> uploadImage(StoreModel? currentStore) async {
    if (croppedImg.value != null) {
      try {
        print('photoSize init ');
        String imageId = powersync.uuid.v4();
        print('photoSize path ${croppedImg.value!.path}');
        String storageDirectory = await attachmentQueue.getStorageDirectory();
        await attachmentQueue.localStorage
            .copyFile(croppedImg.value!.path, '$storageDirectory/$imageId.jpg');

        int photoSize = await croppedImg.value!.length();
        if (currentStore != null && currentStore.logoUrl != null) {
          await attachmentQueue.deleteFile(currentStore.logoUrl!.value);
        }
        await attachmentQueue.saveFile(imageId, photoSize);

        return imageId;
      } catch (e) {
        Get.snackbar('Error', e.toString());
        return null;
      }
    } else {
      return null;
    }
  }

  final loadingLogo = false.obs;

  Future<void> uploadLogoHandle() async {
    Get.defaultDialog(
      title: 'Mengunggah logo...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    loadingLogo.value = true;
    try {
      // await Future.delayed(const Duration(seconds: 3));
      final logoUrl = await uploadImage(store.value);
      print('logoUrl $logoUrl');
      store.value!.logoUrl!.value = logoUrl ?? '';
      await storeService.update(store.value!);

      Get.back();
      Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Logo berhasil diunggah',
        confirm: TextButton(
          onPressed: () async {
            // store.value = await storeService.getStore(store.value!.id!);
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
      // await Future.delayed(const Duration(seconds: 3));
      // store.value = await storeService.getStore(store.value!.id!);
      // store.value.logoUrl =
      displayImg.value = croppedImg.value;
      loadingLogo.value = false;
    } catch (e) {
      Get.back();
      debugPrint(e.toString());
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Terjadi kesalahan saat mengunggah logo',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
      loadingLogo.value = false;
    }
  }

  Future<void> registerWorker() async {
    if (formCashierKey.currentState?.validate() ?? false) {
      Get.defaultDialog(
        title: 'Menambahkan kasir...',
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );
      try {
        String id = cashiers.isNotEmpty
            ? (int.parse(cashiers.last.id.toString()) + 1).toString()
            : '1';
        final Cashier newCashier = Cashier(
          id: id,
          createdAt: DateTime.now(),
          name: nameController.text,
          password: passwordController.text,
          accessList: <String>[].obs,
        );
        var updatedAccount = AccountModel.fromJson(account.toJson());
        print(updatedAccount.users.length);

        updatedAccount.users.add(newCashier);

        await accountService.update(updatedAccount);
        authService.store(await storeService.getStore(account.value!.storeId!));

        authService.account.value!.users.add(newCashier);
        authService.getCashier();

        nameController.text = '';
        passwordController.text = '';
        Get.back();
      } catch (e) {
        Get.back();
        debugPrint(e.toString());
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Terjadi kesalahan tidak terduga',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    }
  }

  Future<void> removeCashier(AccountModel foundAccount, Cashier cashier) async {
    AppDialog.show(
      title: 'Hapus Kasir',
      content: 'Hapus Kasir ini?',
      confirmText: "Ya",
      cancelText: "Tidak",
      confirmColor: Colors.grey,
      cancelColor: Get.theme.primaryColor,
      onConfirm: () async {
        foundAccount.users.remove(cashier);
        await accountService.update(foundAccount);
        authService.store(await storeService.getStore(account.value!.storeId!));
        authService.getCashier();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

//CheckBoxHandle
  void checkBoxHandle(Cashier cashier, String accessName) {
    if (cashier.accessList.contains(accessName)) {
      cashier.accessList.remove(accessName);
    } else {
      cashier.accessList.add(accessName);
    }
    print(cashier.accessList);
  }

  Future<void> saveAccess(AccountModel editedAccount) async {
    AppDialog.show(
      title: 'Simpan',
      content: 'Simpan Perubahan?',
      confirmText: "Ya",
      cancelText: "Tidak",
      onConfirm: () async {
        await accountService.update(editedAccount);
        authService.store(await storeService.getStore(account.value!.storeId!));
        authService.account.value = await accountService.get();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

//!Change PIN
  final oldPinController = TextEditingController();
  final newPinController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  final hideOldPassword = true.obs;
  final hideNewPassword = true.obs;

  void toggleHidePassword(String section) {
    section == 'oldPin'
        ? hideOldPassword.value = !hideOldPassword.value
        : hideNewPassword.value = !hideNewPassword.value;
  }

  String? validateOldPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN tidak boleh kosong';
    }
    return null;
  }

  String? validateNewPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN tidak boleh kosong';
    }
    return null;
  }

  Future<void> changePinHandle() async {
    if (authService.account.value!.password == oldPinController.text) {
      if (oldPinController.text != newPinController.text) {
        if ((formkey.currentState?.validate() ?? false)) {
          Get.defaultDialog(
            title: 'Mengubah PIN..',
            content: const CircularProgressIndicator(),
            barrierDismissible: false,
          );
          try {
            AccountModel updatedAccount =
                AccountModel.fromJson(authService.account.toJson());
            updatedAccount.password = newPinController.text;
            await accountService.update(updatedAccount);
            authService
                .store(await storeService.getStore(account.value!.storeId!));

            oldPinController.text = '';
            newPinController.text = '';
            Get.back();
            Get.back();

            await Get.defaultDialog(
              title: 'Berhasil',
              middleText: 'Pin berhasil diubah.',
            );
          } catch (e) {
            Get.back();
            debugPrint(e.toString());
            Get.defaultDialog(
              title: 'Error',
              middleText: 'Terjadi kesalahan tidak terduga',
              confirm: TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            );
          }
        }
      } else {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'PIN sama dengan sebelumnya',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    } else {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'PIN sebelumnya tidak sesuai',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }
}
