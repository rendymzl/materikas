import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/store_model.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/otp/otp_popup.dart';

class SignupController extends GetxController {
  // Controllers for text fields
  final AccountService _accountService = Get.put(AccountService());
  final StoreService _storeService = Get.put(StoreService());
  final AuthService _authService = Get.put(AuthService());
  var nameFieldC = TextEditingController();
  var phoneFieldC = TextEditingController();
  var passwordFieldC = TextEditingController();
  var confirmPasswordFieldC = TextEditingController();

  // Observable values for password visibility
  var hidePassword = true.obs;
  var hideConfirmPassword = true.obs;

  // Observable map to track if a field has been clicked
  var clickedField = {
    'name': false.obs,
    'phone': false.obs,
    'password': false.obs,
    'confirm_password': false.obs,
  };

  // Toggle password visibility
  void toggleHidePassword() {
    hidePassword.value = !hidePassword.value;
  }

  void toggleHideConfirmPassword() {
    hideConfirmPassword.value = !hideConfirmPassword.value;
  }

  // Validators
  String? validatorName(String value) {
    if (clickedField['name']!.value && value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  String? validatorPhone(String value) {
    if (clickedField['phone']!.value && value.isEmpty) {
      return 'Nomor WhatsApp tidak boleh kosong';
    }
    if (clickedField['phone']!.value && !GetUtils.isPhoneNumber(value)) {
      return 'Nomor WhatsApp tidak valid';
    }
    return null;
  }
  // String? validatorEmail(String value) {
  //   if (clickedField['email']!.value && value.isEmpty) {
  //     return 'Email tidak boleh kosong';
  //   }
  //   if (clickedField['email']!.value && !GetUtils.isEmail(value)) {
  //     return 'Email tidak valid';
  //   }
  //   return null;
  // }

  String? validatorPassword(String value) {
    if (clickedField['password']!.value && value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (clickedField['password']!.value && value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? validatorConfirmPassword(String value) {
    if (clickedField['confirm_password']!.value && value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (clickedField['confirm_password']!.value &&
        value != passwordFieldC.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  // Sign up function
  Future<void> signUpWithEmail(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      try {
        Get.defaultDialog(
          title: 'Membuat akun...',
          content: const CircularProgressIndicator(),
          barrierDismissible: false,
        );

        AccountModel account = AccountModel(
          // id: ,
          accountId: '',
          name: nameFieldC.text.trim(),
          email: '${phoneFieldC.text.trim()}@materikas.com',
          role: 'owner',
          createdAt: DateTime.now().toLocal(),
          users: <Cashier>[].obs,
          password: '',
          accountType: 'setup',
          updatedAt: DateTime.now().toLocal(),
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          isActive: false,
        );

        Get.back();

        bool verivied = await otpPopup(phoneFieldC.text);

        if (verivied) {
          Get.defaultDialog(
            title: 'Mendaftarkan akun...',
            content: const CircularProgressIndicator(),
            barrierDismissible: false,
          );
          final AuthResponse userCredential =
              await Supabase.instance.client.auth.signUp(
            email: '${phoneFieldC.text.trim()}@materikas.com',
            password: passwordFieldC.text,
          );

          StoreModel newStore = StoreModel(
            ownerId: userCredential.user?.id ?? '',
            name: RxString(''),
            address: RxString(''),
            phone: RxString(phoneFieldC.text.trim()),
            telp: RxString(''),
            promo: RxString(''),
            createdAt: DateTime.now().toLocal(),
          );
          print('menambahkan store');
          await _storeService.insert(newStore);

          // var store = await _authService.getStore();
          print('mengambil store: ${userCredential.user?.id}');
          var store = await _storeService.getStore(userCredential.user!.id);

          print('store ${store.toJson()}');
          account.id = userCredential.user?.id ?? '';
          account.storeId = store.id;
          account.accountId = userCredential.user?.id ?? '';

          await _accountService.insert(account);
          Get.back();
          Get.offNamed(Routes.SPLASH);
        }

        // await account.insert();
        // await sideMenuC.handleInit();

        // Get.snackbar(
        //   'Pendaftaran Berhasil',
        //   'Akun telah berhasil dibuat!',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
      } catch (e) {
        Get.back();
        Get.snackbar(
          'Pendaftaran Gagal',
          'Mohon periksa kembali isian form!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        debugPrint(e.toString());
      }
    }
  }

  @override
  void onClose() {
    nameFieldC.dispose();
    phoneFieldC.dispose();
    passwordFieldC.dispose();
    confirmPasswordFieldC.dispose();
    super.onClose();
  }
}
