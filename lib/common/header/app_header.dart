import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.child,
    this.height = 110,
    this.color,
    this.curveOutside = false,
    this.curveRightSide = false,
  });

  final Widget? child;

  final double? height;

  final Color? color;

  final bool curveOutside;

  final bool curveRightSide;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: CustomCurvedEdges(curveOutside: curveOutside, curveRightSide: curveRightSide),
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            width: double.maxFinite,
            height: height,
            color: color ?? AppColors.primary,
            child: child,
          ),
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(height ?? 100);
}


class CustomCurvedEdges extends CustomClipper<Path> {
  final bool curveOutside;
  final bool curveRightSide;
  
  double curveHeight = 25;
  double curveWidth = 40;
  double curveAmount = 8;

  CustomCurvedEdges({super.reclip, this.curveOutside = false, this.curveRightSide = true});

  @override
  Path getClip(Size size) {
    double height = size.height;
    if (curveOutside){
      height = height - curveHeight;
      curveHeight = -1 * curveHeight;
    }

    var path = Path();
    path.lineTo(0, height);

    final fristCurve = Offset(curveAmount, height - curveHeight);
    final lastCurve = Offset(curveWidth, height - curveHeight);
    path.quadraticBezierTo(
        fristCurve.dx, fristCurve.dy, lastCurve.dx, lastCurve.dy);

    
    
    path.lineTo(size.width - curveWidth, height - curveHeight);

    if (curveRightSide){
      final theirdfristCurve = Offset(size.width - curveAmount, height - curveHeight);
      final theirdlastCurve = Offset(size.width, height);
      path.quadraticBezierTo(theirdfristCurve.dx, theirdfristCurve.dy,
          theirdlastCurve.dx, theirdlastCurve.dy);
    } else {
      path.lineTo(size.width, height - curveHeight);
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}