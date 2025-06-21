import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/store_model.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/otp/otp_popup.dart';
// import '../../splash/controllers/handle_setup_widget.dart';

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

          final storeId = uuid.v4();
          final accId = uuid.v4();

          AccountModel newAccount = AccountModel(
            id: accId,
            accountId: userCredential.user?.id ?? '',
            storeId: storeId,
            name: nameFieldC.text.trim(),
            email: '${phoneFieldC.text.trim()}@materikas.com',
            role: 'owner',
            createdAt: DateTime.now(),
            users: <Cashier>[].obs,
            password: '',
            accountType: 'setup',
            updatedAt: DateTime.now(),
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 7)),
            isActive: true,
            token: 2000,
          );

          StoreModel newStore = StoreModel(
            id: storeId,
            ownerId: userCredential.user?.id ?? '',
            name: RxString(''),
            address: RxString(''),
            phone: RxString(phoneFieldC.text.trim()),
            telp: RxString(''),
            promo: RxString(''),
            createdAt: DateTime.now().toLocal(),
          );

          await _storeService.directInsert(newStore);
          await _accountService.directInsert(newAccount);

          _authService.store.value = newStore;
          _authService.account.value = newAccount;
          Get.back();
          // await handleSetup();
          await Get.find<InternetService>().onClose();
          Get.offNamed(Routes.SPLASH);
        }
      } catch (e) {
        Get.back();
        if (e.toString().contains('User already registered')) {
          Get.snackbar(
            'Pendaftaran Gagal',
            'Email sudah terdaftar!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Pendaftaran Gagal',
            'Mohon periksa kembali isian form!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
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
