import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/entities/account.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/user_model.dart';

class SignupController extends GetxController {
  // Controllers for text fields
  final AuthService _authService = Get.find<AuthService>();
  var nameFieldC = TextEditingController();
  var emailFieldC = TextEditingController();
  var passwordFieldC = TextEditingController();
  var confirmPasswordFieldC = TextEditingController();

  // Observable values for password visibility
  var hidePassword = true.obs;
  var hideConfirmPassword = true.obs;

  // Observable map to track if a field has been clicked
  var clickedField = {
    'name': false.obs,
    'email': false.obs,
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

  String? validatorEmail(String value) {
    if (clickedField['email']!.value && value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (clickedField['email']!.value && !GetUtils.isEmail(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

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
        final AuthResponse userCredential =
            await Supabase.instance.client.auth.signUp(
          email: emailFieldC.text.trim(),
          password: passwordFieldC.text,
        );

        AccountModel account = AccountModel(
          accountId: userCredential.user!.id,
          name: nameFieldC.text.trim(),
          email: emailFieldC.text.trim(),
          role: 'owner',
          createdAt: DateTime.now().toLocal(),
          users: <Cashier>[].obs,
          password: '',
          accountType: 'setup',
          updatedAt: DateTime.now().toLocal(),
          storeId: _authService.store.value!.id,
        );

        _authService.insert(account);

        // await account.insert();
        // await sideMenuC.handleInit();

        Get.snackbar(
          'Pendaftaran Berhasil',
          'Akun telah berhasil dibuat!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } on AuthException catch (e) {
        Get.snackbar(
          'Pendaftaran Gagal',
          'Mohon periksa kembali isian form!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        debugPrint(e.message);
      }
    }
  }

  @override
  void onClose() {
    nameFieldC.dispose();
    emailFieldC.dispose();
    passwordFieldC.dispose();
    confirmPasswordFieldC.dispose();
    super.onClose();
  }
}
