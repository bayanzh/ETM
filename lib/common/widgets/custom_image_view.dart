import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('assets')) {
      return ImageType.png;
    } else {
      return ImageType.file;
    } 
  }
}

enum ImageType { network, svg, png, file }

// ignore_for_file: must_be_immutable
class CustomImageView extends StatelessWidget {
  CustomImageView({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.padding,
    this.border,
    this.placeHolder = 'assets/images/image_not_found.png',
    this.displayClickEffect,
  });

  ///[imagePath] is required parameter for showing image
  String imagePath;

  double? height;

  double? width;

  Color? color;

  BoxFit? fit;

  final String placeHolder;

  Alignment? alignment;

  VoidCallback? onTap;

  EdgeInsetsGeometry? margin;
  
  EdgeInsetsGeometry? padding;

  BorderRadius? radius;

  BoxBorder? border;

  bool? displayClickEffect;

  @override
  Widget build(BuildContext context) {
   
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget())
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: _buildImageWithBorder(),
      ),
    );
  }

  _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageWithPAdding(),
      );
    } else {
      return _buildImageWithPAdding();
    }
  }

  _buildImageWithPAdding() {
    if (padding != null) {
      return Container(
        padding: padding,
        child: _buildCircleImage(),
      );
    } else {
      return _buildCircleImage();
    }
  }

  ///build the image with border radius
  _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    if (imagePath.isEmpty)  return const SizedBox();
    switch (imagePath.imageType) {
      case ImageType.svg:
        return SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            imagePath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color ?? Colors.transparent, BlendMode.srcIn)
                : null,
          ),
        );
      case ImageType.file:
        return Image.file(
          File(imagePath),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
        case ImageType.network:
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: imagePath,
            color: color,
            placeholder: (context, url) => SizedBox(
              height: 30,
              width: 30,
              child: LinearProgressIndicator(
                color: Colors.grey.shade200,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              placeHolder,
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
            ),
          );
      case ImageType.png:
      default:
        return Image.asset(
          imagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
    }
  }
}
