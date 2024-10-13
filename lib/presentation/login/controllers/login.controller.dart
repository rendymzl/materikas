import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/dal/services/auth_service.dart';

class LoginController extends GetxController {
  //! UI ====
  final hidePassword = true.obs;
  final isLoading = false.obs;

  void toggleHidePassword() {
    hidePassword.value = !hidePassword.value;
  }

  //! Function ====
  final AuthService _authService = Get.find<AuthService>();
  final emailFieldC = TextEditingController();
  final passwordFieldC = TextEditingController();

  // final formkey = GlobalKey<FormState>();
  // final clicked = false.obs;

  final clickedField = {'email': false, 'password': false}.obs;

  String? validatorEmail(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['email'] == true) {
      return 'Email tidak boleh kosong';
    }
    // final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // if (!emailRegex.hasMatch(value)) {
    //   return 'Email tidak valid';
    // }
    return null;
  }

  String? validatorPassword(String value) {
    if (value.isEmpty && clickedField['password'] == true) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  Future<void> signInWithEmail(GlobalKey<FormState> formkey) async {
    if (formkey.currentState!.validate()) {
      isLoading.value = true;
      String email = emailFieldC.text.trim();
      if (int.tryParse(email) != null && !email.contains('@')) {
        email += '@materikas.com';
      }
      await _authService.login(email, passwordFieldC.text);
    }
  }

  Future<void> clearDb() async {
    Get.defaultDialog(
      content: const CircularProgressIndicator(),
    );
    await db.disconnectAndClear();
    Get.back();
  }
}
