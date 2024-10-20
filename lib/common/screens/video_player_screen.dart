import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

extension VideoTypeExtension on String {
  VideoType get videoType {
    if (startsWith('http') || startsWith('https')) {
      return VideoType.network;
    } else if (endsWith('.mp4') || endsWith('.avi') || endsWith('.mkv') || endsWith('.mov')) {
      return VideoType.file;
    } else if (startsWith('assets')) {
      return VideoType.asset;
    } else {
      return VideoType.unknown;
    }
  }
}

enum VideoType { network, file, asset, unknown }


class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.buildAsScreen = true,
    this.allowFullScreen = true,
    this.autoPlay = true,
    this.width,
    this.height,
  });

  final String videoUrl;
  final bool buildAsScreen;
  final bool allowFullScreen;
  final bool autoPlay;
  final double? width;
  final double? height;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController; // للتحكم بواجهة المستخدم للفيديو
  double viewingRate = 0.0; // متغير لحساب معدل المشاهدة

  @override
  void initState() {
    super.initState();
    // final url = Uri.parse(widget.videoUrl);
    if (widget.videoUrl.videoType == VideoType.network) {
      final url = Uri.parse(widget.videoUrl);
      _videoController = VideoPlayerController.networkUrl(url);
    } else if (widget.videoUrl.videoType == VideoType.file){
      final url = File(widget.videoUrl);
      _videoController = VideoPlayerController.file(url);
    }

    _videoController.initialize().then((_) {
      if (mounted){
        setState(() {});

        // initilaize ChewieController to set up the control interface
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          aspectRatio: _videoController.value.aspectRatio, // الحفاظ على نسبة الأبعاد للفيديو
          autoPlay: widget.autoPlay,
          looping: false,
          materialProgressColors: ChewieProgressColors(playedColor: AppColors.primary),
          zoomAndPan: true,
          useRootNavigator: true,
          allowFullScreen: widget.allowFullScreen,
        );

        if (widget.buildAsScreen) {
          _videoController.addListener(() {
            _updateViewingRate();

            if (_videoController.value.position == _videoController.value.duration) {
              Get.back(closeOverlays: true, result: viewingRate);
            }
          });
        }
      } else {
        _videoController.dispose();
      }
    }, onError: (erroe) {
      Logger.logError('Error while opening video: $erroe');
      Get.back(closeOverlays: true, result: viewingRate);
      AppHelper.showToastSnackBar(
        message: 'Unexpected error while opening video, please contact support to solve the problem.',
        isError: true,
      );
    });
  }

  @override
  void dispose() {
    _videoController.removeListener(_updateViewingRate);
    _videoController.dispose();
    
    if (_videoController.value.isInitialized) {
      _videoController.pause();
      _chewieController.pause();
      _chewieController.dispose();
    }
    super.dispose();
  }

  void _updateViewingRate() {
    final currentPosition = _videoController.value.position.inSeconds.toDouble();
    final totalDuration = _videoController.value.duration.inSeconds.toDouble();
    
    viewingRate = currentPosition / totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buildAsScreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          Logger.log("Viewing Rate: $viewingRate");
          if (didPop) return;

          Get.back(closeOverlays: true, result: viewingRate);
        },
        child: Scaffold(
          backgroundColor: Colors.grey[850],
          body: _buildVideoWidget(),
        ),
      );
    } else {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: _buildVideoWidget(),
      );
    }
  }

  Widget _buildVideoWidget() {
    return _videoController.value.isInitialized
        ? Chewie(controller: _chewieController)
        : Center(child: AppHelper.custumProgressIndecator(size: 55));
  }
}
