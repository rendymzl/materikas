import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class LoginController extends GetxController {
  //! UI ====
  final isLoginPage = true.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs;

  void toggleLoginPage() {
    isLoginPage.value = !isLoginPage.value;
  }

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
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
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
      await _authService.login(emailFieldC.text.trim(), passwordFieldC.text);
    }
  }

  Future<void> signUpWithEmail() async {
    // try {
    //   final AuthResponse userCredential =
    //       await Supabase.instance.client.auth.signUp(
    //     email: emailFieldC.text.trim(),
    //     password: passwordFieldC.text,
    //   );

    //   Account account = Account(
    //       accountId: userCredential.user!.id,
    //       name: '',
    //       email: emailFieldC.text.trim(),
    //       role: 'owner',
    //       createdAt: DateTime.now().toLocal());

    //   await account.insert();
    //   // await Account.insert(account);
    //   await sideMenuC.handleInit();

    //   debugPrint('daftar berhasil: ${account.name}');
    // } on AuthException catch (e) {
    //   debugPrint(e.message);
    // }
  }
}
