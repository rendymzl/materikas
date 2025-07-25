import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../infrastructure/navigation/routes.dart';
import '../global_widget/app_dialog_widget.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();
    OutlineInputBorder outlineRed =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          // surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () async {
                  AppDialog.show(
                    title: 'Refresh',
                    content: 'Bersihkan data?',
                    confirmText: "Ya",
                    cancelText: "Tidak",
                    confirmColor: Colors.grey,
                    cancelColor: Get.theme.primaryColor,
                    onConfirm: () => controller.clearDb(),
                    onCancel: () => Get.back(),
                  );
                },
                icon: const Icon(Symbols.refresh))
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 400,
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Selamat datang',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    Obx(
                      () => Form(
                        key: formkey,
                        autovalidateMode: AutovalidateMode.always,
                        onChanged: () =>
                            Form.of(primaryFocus!.context!).save(),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: controller.emailFieldC,
                              decoration: InputDecoration(
                                labelText: "Email / Whatsapp",
                                prefixIcon:
                                    const Icon(Symbols.email, fill: 1),
                                labelStyle:
                                    const TextStyle(color: Colors.grey),
                                floatingLabelStyle:
                                    const TextStyle(color: Colors.black),
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey)),
                                focusedErrorBorder: outlineRed,
                                errorBorder: outlineRed,
                              ),
                              onChanged: (value) =>
                                  controller.clickedField['email'] = true,
                              validator: (value) =>
                                  controller.validatorEmail(value!),
                              onFieldSubmitted: (_) =>
                                  controller.signInWithEmail(formkey),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: controller.passwordFieldC,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon:
                                    const Icon(Symbols.lock, fill: 1),
                                suffixIcon: IconButton(
                                  icon: const Icon(Symbols.remove_red_eye,
                                      fill: 1),
                                  onPressed: () =>
                                      controller.toggleHidePassword(),
                                ),
                                labelStyle:
                                    const TextStyle(color: Colors.grey),
                                floatingLabelStyle:
                                    const TextStyle(color: Colors.black),
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey)),
                                focusedErrorBorder: outlineRed,
                                errorBorder: outlineRed,
                              ),
                              onChanged: (value) => controller
                                  .clickedField['password'] = true,
                              validator: (value) =>
                                  controller.validatorPassword(value!),
                              obscureText: controller.hidePassword.value,
                              onFieldSubmitted: (_) =>
                                  controller.signInWithEmail(formkey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                controller.signInWithEmail(formkey),
                            child: const Text(
                              'Masuk',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // GestureDetector(
                        //   child: const Text(
                        //     'Lupa Password',
                        //     style:
                        //         TextStyle(fontSize: 12, color: Colors.red),
                        //   ),
                        //   onTap: () {},
                        // ),
                        Row(
                          children: [
                            const Text(
                              'Belum punya akun? ',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                child: const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                                onTap: () => Get.offAllNamed(Routes.SIGNUP),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
