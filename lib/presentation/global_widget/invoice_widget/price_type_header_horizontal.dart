import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../../infrastructure/dal/services/auth_service.dart';
import '../date_picker_widget/date_picker_widget.dart';

class HorizontalPriceTypeView extends StatelessWidget {
  final RxInt priceType;
  final Rx<DateTime?> datetime;

  const HorizontalPriceTypeView({
    super.key,
    required this.priceType,
    required this.datetime,
  });

  @override
  Widget build(BuildContext context) {
    // final authService = Get.find<AuthService>();
    // final isArcaNusantara =
    //     authService.account.value!.name.toLowerCase() == 'arca nusantara';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          children: [
            _buildPriceTypeItem(
                context, '2', priceType, 2),
            _buildPriceTypeItem(
                context, '3', priceType, 3),
          ],
        ),
        DatePickerWidget(dateTime: datetime),
      ],
    );
  }

  Widget _buildPriceTypeItem(
    BuildContext context,
    String priceTypeName,
    RxInt priceType,
    int priceTypeValue,
  ) {
    return Obx(() => InkWell(
          onTap: () => priceType.value =
              priceTypeValue == priceType.value ? 1 : priceTypeValue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Checkbox(
                  value: priceType.value == priceTypeValue,
                  onChanged: (_) => priceType.value =
                      priceTypeValue == priceType.value ? 1 : priceTypeValue,
                  splashRadius: 0,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                Text(
                  'Harga $priceTypeName',
                  style: priceType.value == priceTypeValue
                      ? context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)
                      : context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ));
  }
}
