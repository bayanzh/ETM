import 'package:e_training_mate/common/widgets/app_primary_button.dart';
import 'package:e_training_mate/common/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';

// This class represents a success screen widget that displays an image, a title, and a button.
class SuccessScreen extends StatelessWidget {
  // The constructor for the SuccessScreen widget, which requires an image path, a title, and a callback function for the button press.
  const SuccessScreen({
    super.key,
    this.image,
    required this.title,
    required this.onTapOk,
  });

  // The image path to be displayed on the success screen.
  final String? image;

  // The title to be displayed on the success screen.
  final String title;

  // The callback function to be executed when the button is pressed.
  final VoidCallback onTapOk;

  // The build method for the SuccessScreen widget, which returns a Scaffold containing a SingleChildScrollView with a Column of widgets.
  @override
  Widget build(BuildContext context) {
    // Get the height of the screen.
    var height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        child: Column(
          children: [
            // Display the image using the SvgPicture.asset method.
            if (image != null) CustomImageView(imagePath: image!),

            // Display the title using the Text widget.
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            // Add some vertical space between the title and the button.
            SizedBox(
              height: height * 0.05,
            ),

            // Display the button using the RoundedButton widget.
            AppPrimaryButton(
              text: "Continue",
              onTap: onTapOk,
            ),
          ],
        ),
      ),
    );
  }
}
