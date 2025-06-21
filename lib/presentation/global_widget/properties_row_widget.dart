import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PropertiesRowWidget extends StatelessWidget {
  const PropertiesRowWidget({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.primary = false,
    this.italic = false,
    this.color,
  });

  final String title;
  final String value;
  final String? subValue;
  final bool primary;
  final bool italic;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: primary
                        ? context.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: italic ? FontStyle.italic : null,
                            color: color)
                        : context.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontStyle: italic ? FontStyle.italic : null,
                            color: color)),
                Row(
                  children: [
                    Text(
                      subValue != null
                          ? subValue!.isEmpty ||
                                  subValue == '0' ||
                                  subValue == '-0'
                              ? '-'
                              : '$subValue'
                          : '',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontStyle: FontStyle.italic, color: color),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
          Text(
            value == '0' || value == '-0'
                ? '-'
                : value == 'title'
                    ? ''
                    : value,
            style: primary
                ? context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: italic ? FontStyle.italic : null,
                    color: color)
                : context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                    fontStyle: italic ? FontStyle.italic : null,
                    color: color),
          )
        ],
      ),
    );
  }
}
