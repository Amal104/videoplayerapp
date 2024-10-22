import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoController extends ChangeNotifier {
  List data = [];
  bool playArea = false;
  VideoPlayerController? controller;
  ChewieController? chewieController;

  Future getJsonProverb() async {
  final String rawJson = await rootBundle.loadString('json/videoinfo.json');
  data = jsonDecode(rawJson);
  debugPrint(data.toString());
  return await jsonDecode(rawJson);
}

  videoInitialize(String url) {
    controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: controller!,
          aspectRatio: controller!.value.aspectRatio,
          autoPlay: true,
          autoInitialize: true,
          additionalOptions: (context) {
            return <OptionItem>[
              OptionItem(
                onTap: () {
                  debugPrint('My option works!');
                },
                iconData: Icons.download,
                title: 'Download',
              ),
            ];
          },
        );
        notifyListeners();
      });
  }

  void onVideoTap(String url) {
    videoInitialize(url);
  }

  void playAreaCheck() {
    if (playArea == false) {
      playArea = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    chewieController?.dispose();
    super.dispose();
  }
}
