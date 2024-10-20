import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/helpers/validation_helper.dart';
import 'app_primary_button.dart';
import 'custom_outlined_button.dart';
import 'custom_search_view.dart';

class SendNotificationWidget extends StatefulWidget {
  const SendNotificationWidget({super.key, this.onSend});

  final void Function(String title, String? body)? onSend;

  @override
  State<SendNotificationWidget> createState() => _SendNotificationWidgetState();
}

class _SendNotificationWidgetState extends State<SendNotificationWidget> {
  final formKey = GlobalKey<FormState>();
  final titleCon = TextEditingController();
  final bodyCon = TextEditingController();

  late AnimationController animationCon;

  late CurvedAnimation scaleAnimation;


  @override
  void initState() {
    super.initState();

    animationCon = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 450),
    );

    scaleAnimation = CurvedAnimation(
      parent: animationCon..forward(),
      curve: Curves.easeIn,
      reverseCurve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    child: Text('Send a notification\n To all course participants'.tr,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium),
                  ),
                  const SizedBox(height: 20),
                  
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(' ${"Notification Title".tr}'),
                        CustomSearchView(
                          isSearchForm: false,
                          hintText: "Enter notification title",
                          controller: titleCon,
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          validator: ValidationHelper.emptyValidator,
                        ),
                        
                        Text(' ${"Notification Body (optional)".tr}'),
                        CustomSearchView(
                          isSearchForm: false,
                          hintText: "Enter notification body",
                          controller: bodyCon,
                          maxLines: 3,
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                        ),
                      ],
                    ),
                  ),                  
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppPrimaryButton(
                        text: "Send",
                        height: 37,
                        textStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
                        onTap: () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;

                          Get.closeAllSnackbars();
                          await animationCon.reverse();
                          Navigator.of(Get.overlayContext!).pop(true);
                          widget.onSend?.call(titleCon.text.trim(), bodyCon.text.trim());
                        },
                      ),
                  
                      CustomOutlinedButton(
                        text: "Cancel",
                        height: 37,
                        buttonTextStyle: textTheme.bodyMedium,
                        onPressed: () async {
                          Get.closeAllSnackbars();
                          await animationCon.reverse();
                          Navigator.of(Get.overlayContext!).pop(false);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
