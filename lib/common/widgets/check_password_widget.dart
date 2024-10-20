import 'dart:developer';

import 'package:e_training_mate/core/utils/helpers/validation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckPasswordWidget extends StatelessWidget {
  const CheckPasswordWidget({super.key, required this.onCorrectCheck});

  final void Function(String password) onCorrectCheck;

  CheckPasswordController get controller => Get.put(CheckPasswordController());

  @override
  Widget build(BuildContext context) {
  

    final animationCon = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 450),
    );

    final scaleAnimation = CurvedAnimation(
      parent: animationCon..forward(),
      curve: Curves.easeIn,
      reverseCurve: Curves.elasticOut,
    );

    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: AlignmentDirectional.center,
                margin: const EdgeInsets.all(10),
                child: Text("Please enter your password".tr),
              ),
              const SizedBox(height: 5),

              // old password
              Form(
                key: controller.formKey,
                child: Obx(
                  () => TextFormField(
                    onSaved: (val) {
                    },
                    validator: ValidationHelper.emptyValidator,
                    obscureText: controller.securePassword.value,
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      errorText: controller.errorPassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.securePassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => controller.changPasswordVisible(),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      prefixIcon: const Icon(Icons.password_rounded),
                      hintText: 'Password'.tr,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),



              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await animationCon.reverse();
                        Get.back(result: false);
                      },
                      child: Text("Cancel".tr),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => TextButton(
                        onPressed: () async {
                          Get.focusScope?.unfocus();
                          if (await controller.checkPassword()) {
                            await animationCon.reverse();
                            onCorrectCheck(controller.passwordController.text.trim());
                            Get.back(result: true);
                          }
                        },
                        child: controller.isWaiting.value
                            ? const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(),
                              )
                            : Text("Check".tr),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CheckPasswordController extends GetxController {
  late GlobalKey<FormState> formKey;
  RxBool securePassword = true.obs;
  late TextEditingController passwordController;
  Rx<String?> errorPassword = Rx(null);
  RxBool isWaiting = false.obs;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
 
    super.onClose();
   
  }

  void changPasswordVisible() {
    securePassword.value = !securePassword.value;
  }

  Future<bool> checkPassword() async {
    try {
      if (!(formKey.currentState?.validate() ?? false)) return false;

      isWaiting.value = true;

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        log("::::::::::::User password: ${passwordController.text}");

        // Create a credential with the provided password
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: passwordController.text.trim());

        log("::::::::::::After credential: ${user.uid}");

        // Reauthenticate the user with the credential
        await user.reauthenticateWithCredential(credential);

        // Password is correct
        isWaiting.value = false;
        return true;
      } else {
        log('::::::::: User is not signed in.');
        isWaiting.value = false;
        return false;
      }
    } catch (e) {
      log('Failed to check password: $e');
      errorPassword.value = "Failed to check password".tr;
      isWaiting.value = false;
      return false;
    }
  }
}
