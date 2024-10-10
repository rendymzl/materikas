import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopupPageWidget extends StatelessWidget {
  final String title;
  final IconButton? iconButton;
  final Widget content;
  final List<Widget>? buttonList;
  final double width;
  final double height;
  final FocusNode? focusNode;
  final VoidCallback? onClose;

  const PopupPageWidget({
    super.key,
    required this.title,
    this.iconButton,
    required this.content,
    this.buttonList,
    this.width = 300,
    this.height = 400,
    this.focusNode,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focusNode?.requestFocus(),
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) async {
          onClose?.call();
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      title,
                      style: context.textTheme.titleLarge,
                      textAlign: iconButton != null ? null : TextAlign.center,
                    ),
                    trailing: iconButton,
                  ),
                  // const SizedBox(height: 20),
                  Expanded(child: ListView(children: [content])),
                  if (buttonList != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: buttonList!,
                      ),
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

Future<void> showPopupPageWidget({
  required String title,
  IconButton? iconButton,
  required Widget content,
  List<Widget>? buttonList,
  double width = 300,
  double height = 400,
  FocusNode? focusNode,
  bool barrierDismissible = false,
  VoidCallback? onClose,
}) async {
  await Get.dialog(
    PopupPageWidget(
      title: title,
      iconButton: iconButton,
      content: content,
      buttonList: buttonList,
      width: width,
      height: height,
      focusNode: focusNode,
      onClose: onClose,
    ),
    barrierDismissible: !barrierDismissible,
  );
}
