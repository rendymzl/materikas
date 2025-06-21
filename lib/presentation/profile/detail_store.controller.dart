import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../infrastructure/dal/services/store_service.dart';
import '../../infrastructure/models/store_model.dart';
import '../global_widget/app_dialog_widget.dart';

class DetailStoreController extends GetxController {
  final AuthService authService = Get.find();
  final StoreService storeService = Get.find();

  late final store = authService.store;

  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeTelpController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  final clickedField = {
    'name': false,
    'address': false,
    'phone': false,
    'telp': false,
  }.obs;

  String? nameValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['name'] == true) {
      return 'Nama tidak boleh kosong';
    } else if (value.length < 3 && clickedField['name'] == true) {
      return 'Nama harus di isi minimal 3 karakter';
    }
    return null;
  }

  late String customerId;

  //! binding data
  void bindingEditData(StoreModel? store) {
    StoreModel bindStore = store ??
        StoreModel(
            name: 'Nama Toko'.obs,
            address: "Alamat Toko".obs,
            phone: "Nomor HP".obs,
            telp: "Nomor Telp".obs,
            id: '',
            createdAt: DateTime.now());
    storeNameController.text = bindStore.name.value;
    storeAddressController.text = bindStore.address.value;
    storePhoneController.text = bindStore.phone.value;
    storeTelpController.text = bindStore.telp.value;
  }

  //! create
  Future addStore(StoreModel store) async {
    await storeService.insert(store);
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Toko berhasil ditambahkan',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    authService.store(
        await storeService.getStore(authService.account.value!.storeId!));
    Get.back();
  }

  //! update
  Future updateStore(
    StoreModel updatedStore,
    StoreModel currentStore,
  ) async {
    updatedStore.id = currentStore.id;
    await storeService.update(updatedStore);
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Toko berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    authService.store(updatedStore);
    Get.back();
  }

  //! delete
  destroyHandle(StoreModel store) async {
    AppDialog.show(
      title: 'Hapus toko',
      content: 'Hapus toko ini?',
      confirmText: "Ya",
      cancelText: "Tidak",
      confirmColor: Colors.grey,
      cancelColor: Get.theme.primaryColor,
      onConfirm: () async {
        storeService.delete(store.id!);
        Get.back();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  //! handle save
  Future handleSave(StoreModel? currentStore) async {
    try {
      clickedField['name'] = true;
      print(storeNameController.text);
      if (formkey.currentState!.validate()) {
        if (currentStore != null) {
          final store = StoreModel.fromJson(currentStore.toJson());
          store.name.value = storeNameController.text;
          store.address.value = storeAddressController.text;
          store.phone.value = storePhoneController.text;
          store.telp.value = storeTelpController.text;
          await updateStore(store, currentStore);
        } else {
          final store = StoreModel(
              name: storeNameController.text.obs,
              address: storeAddressController.text.obs,
              phone: storePhoneController.text.obs,
              telp: storeTelpController.text.obs,
              id: '',
              createdAt: DateTime.now());
          await addStore(store);
        }
      }
    } catch (e) {
      Get.defaultDialog(
        title: 'cekError',
        middleText: 'err: $e',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }
}
