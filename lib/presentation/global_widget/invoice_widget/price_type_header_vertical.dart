import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../date_picker_widget/date_picker_widget.dart';

class VerticalPriceTypeView extends StatelessWidget {
  final RxInt priceType;
  final Rx<DateTime?> datetime;

  const VerticalPriceTypeView({
    super.key,
    required this.priceType,
    required this.datetime,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final isArcaNusantara =
        authService.account.value!.name.toLowerCase() == 'arca nusantara';
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blueGrey[50],
                ),
                child: Obx(
                  () => DropdownButtonFormField<int>(
                    value: priceType.value,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 1,
                        child: Text('Harga Normal'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                            'Harga ${isArcaNusantara ? 'masuk gang' : '2'}'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child:
                            Text('Harga ${isArcaNusantara ? 'material' : '3'}'),
                      ),
                    ],
                    onChanged: (value) {
                      priceType.value = value == priceType.value ? 1 : value!;
                    },
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500, 
                      color: Colors.grey[700],
                    ),
                    dropdownColor: Colors.white,
                    iconEnabledColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            DatePickerWidget(dateTime: datetime),
          ],
        ),
      ],
    );
  }
}
