import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/navigation/routes.dart';
import 'controllers/signup.controller.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    OutlineInputBorder outlineRed =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          width: 400,
          height: 600,
          child: Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.always,
                    onChanged: () => Form.of(primaryFocus!.context!).save(),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.nameFieldC,
                          decoration: InputDecoration(
                            labelText: "Nama",
                            prefixIcon: const Icon(Symbols.person, fill: 1),
                            labelStyle: const TextStyle(color: Colors.grey),
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedErrorBorder: outlineRed,
                            errorBorder: outlineRed,
                          ),
                          onChanged: (value) =>
                              controller.clickedField['name']!.value = true,
                          // onChanged: (_) {
                          //   formKey.currentState!
                          //       .validate(); // Validasi ulang setelah perubahan
                          // },
                          validator: (value) =>
                              controller.validatorName(value!),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controller.emailFieldC,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Symbols.email, fill: 1),
                            labelStyle: const TextStyle(color: Colors.grey),
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedErrorBorder: outlineRed,
                            errorBorder: outlineRed,
                          ),
                          onChanged: (value) =>
                              controller.clickedField['email']!.value = true,
                          validator: (value) =>
                              controller.validatorEmail(value!),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controller.passwordFieldC,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Symbols.lock, fill: 1),
                            suffixIcon: IconButton(
                              icon: const Icon(Symbols.remove_red_eye, fill: 1),
                              onPressed: () => controller.toggleHidePassword(),
                            ),
                            labelStyle: const TextStyle(color: Colors.grey),
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedErrorBorder: outlineRed,
                            errorBorder: outlineRed,
                          ),
                          obscureText: controller.hidePassword.value,
                          onChanged: (value) =>
                              controller.clickedField['password']!.value = true,
                          validator: (value) =>
                              controller.validatorPassword(value!),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controller.confirmPasswordFieldC,
                          decoration: InputDecoration(
                            labelText: "Konfirmasi Password",
                            prefixIcon: const Icon(Symbols.lock, fill: 1),
                            suffixIcon: IconButton(
                              icon: const Icon(Symbols.remove_red_eye, fill: 1),
                              onPressed: () =>
                                  controller.toggleHideConfirmPassword(),
                            ),
                            labelStyle: const TextStyle(color: Colors.grey),
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedErrorBorder: outlineRed,
                            errorBorder: outlineRed,
                          ),
                          obscureText: controller.hideConfirmPassword.value,
                          onChanged: (value) => controller
                              .clickedField['confirm_password']!.value = true,
                          validator: (value) =>
                              controller.validatorConfirmPassword(value!),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => controller.signUpWithEmail(formKey),
                          child: const Text('Daftar'),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () => Get.offAllNamed(Routes.LOGIN),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
