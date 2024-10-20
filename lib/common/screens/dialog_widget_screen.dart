import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogWidgetScreen extends StatefulWidget {
  const DialogWidgetScreen({super.key, required this.child});

  final Widget child;

  @override
  State<DialogWidgetScreen> createState() => _DialogWidgetScreenState();
}

class _DialogWidgetScreenState extends State<DialogWidgetScreen> {
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
  void dispose() {
    animationCon.reverse();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {

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
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
