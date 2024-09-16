import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'add_cashier.dart';
import 'cashier_list.dart';
import 'controllers/profile.controller.dart';
import 'profile_store_widget.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          MenuWidget(title: 'Profile'),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Card(
                          child: ProfileStoreWidget(),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Card(
                          child: AddCashierWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Card(
                    child: CashierListWidget(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
