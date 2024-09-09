import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PropertiesRow extends StatelessWidget {
  const PropertiesRow({
    this.title = '',
    this.value = '',
    this.subValue = '',
    this.primary = false,
    this.subtraction = false,
    this.payment = false,
    this.titleTextAlign = TextAlign.right,
    this.valueTextAlign = TextAlign.right,
    super.key,
  });

  final String title;
  final String value;
  final String subValue;
  final bool primary;
  final bool subtraction;
  final bool payment;
  final TextAlign titleTextAlign;
  final TextAlign valueTextAlign;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: primary
                  ? subtraction
                      ? Theme.of(Get.context!)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.red)
                      : payment
                          ? Theme.of(Get.context!)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.green)
                          : Theme.of(Get.context!).textTheme.titleLarge
                  : subtraction
                      ? Theme.of(Get.context!)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.red)
                      : payment
                          ? Theme.of(Get.context!)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.green)
                          : Theme.of(Get.context!).textTheme.bodyMedium,
              textAlign: titleTextAlign,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
              child: Text(
            value,
            style: primary
                ? subtraction
                    ? Theme.of(Get.context!)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.red)
                    : payment
                        ? Theme.of(Get.context!)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.green)
                        : Theme.of(Get.context!).textTheme.titleLarge
                : subtraction
                    ? Theme.of(Get.context!)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.red)
                    : payment
                        ? Theme.of(Get.context!)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.green)
                        : Theme.of(Get.context!).textTheme.bodyMedium,
            textAlign: valueTextAlign,
          )),
        ],
      ),
    );
  }
}
