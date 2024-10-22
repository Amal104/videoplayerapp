import 'dart:convert';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoController extends ChangeNotifier {
  List data = [];
  bool playArea = false;
  VideoPlayerController? controller;
  ChewieController? chewieController;

  Map<String, bool> isDownloaded = {}; // To track downloaded files
  Map<String, bool> isDownloading = {}; // To track if a video is downloading
  Map<String, double> downloadProgress = {}; // To track download progress
  Map<String, String> errorMessages = {}; // To track errors
  List videoList = [];

  Dio dio = Dio(); // Dio instance

  Future getJsonProverb() async {
    final String rawJson = await rootBundle.loadString('json/videoinfo.json');
    data = jsonDecode(rawJson);
    // debugPrint(data.toString());
    return await jsonDecode(rawJson);
  }

  networkVideoInitialize(String url,) {
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

  localVideoInitialize(String path,) {
    controller = VideoPlayerController.file(File(path))
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

  void initializeDownload() async{
   await getJsonProverb();
    for (int i = 0; i < data.length; i++) {
      videoList.add(data[i]["videoUrl"]);
    }
    debugPrint("video List ${videoList.toString()}");
    for (var url in videoList) {
      isDownloaded[url] = false;
      isDownloading[url] = false;
      downloadProgress[url] = 0.0;
      errorMessages[url] = '';
    }
    checkDownloadedFiles();
  }

  // Check if the videos are already downloaded
  Future<void> checkDownloadedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    for (var url in videoList) {
      final videoPath = '${directory.path}/${url.split('/').last}';
      if (await File(videoPath).exists()) {
        isDownloaded[url] = true;
        notifyListeners();
      }
    }
  }

  // Function to download and encrypt the video
  Future<void> downloadVideo(String url) async {
    try {
      isDownloading[url] = true;
      notifyListeners();
      errorMessages[url] = '';
      notifyListeners(); // Clear any previous errors
      downloadProgress[url] = 0.0; // Reset download progress
      notifyListeners();

      final directory = await getApplicationDocumentsDirectory();
      final videoPath = '${directory.path}/${url.split('/').last}';
      debugPrint(url);

      await dio.download(
        url,
        videoPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress[url] = (received / total) * 100;
            notifyListeners();
          }
        },
      );

      // Encrypt the video after download
      final file = File(videoPath);
      final bytes = await file.readAsBytes();

      final encrypter =
          en.Encrypter(en.AES(en.Key.fromLength(32), mode: en.AESMode.cbc));
      final iv = en.IV.fromLength(16);
      final encrypted = encrypter.encryptBytes(bytes, iv: iv);

      await file.writeAsBytes(encrypted.bytes); // Overwrite with encrypted data

      isDownloaded[url] = true;
      notifyListeners();
    } catch (e) {
      errorMessages[url] = 'Error downloading video: ${e.toString()}';
      notifyListeners();
      debugPrint(e.toString());
    } finally {
      isDownloading[url] = false;
      notifyListeners();
    }
  }

  Future<void> playLocalVideo(String url) async {
    debugPrint("playing local video");
    try {
      debugPrint("playing local video");
      final directory = await getApplicationDocumentsDirectory();
      final videoPath = '${directory.path}/${url.split('/').last}';

      final file = File(videoPath);
      final encryptedBytes = await file.readAsBytes();

      // Decrypt the video
      final encrypter =
          en.Encrypter(en.AES(en.Key.fromLength(32), mode: en.AESMode.cbc));
      final iv = en.IV.fromLength(16);
      final decrypted =
          encrypter.decryptBytes(en.Encrypted(encryptedBytes), iv: iv);

      final tempFile = File('${directory.path}/temp_${url.split('/').last}');
      await tempFile.writeAsBytes(decrypted);

      localVideoInitialize(url);
    } catch (e) {
      errorMessages[url] = 'Error playing video: ${e.toString()}';
      notifyListeners();
      debugPrint(e.toString());
    }
  }

  Future<void> playNetworkVideo(String url) async {
    debugPrint("playing network video");
    try {
      debugPrint("playing network video");
      networkVideoInitialize(url);
    } catch (e) {
      errorMessages[url] = 'Error streaming video: ${e.toString()}';
      notifyListeners();
    }
  }

  // void onVideoTap(String url) {
  //   videoInitialize(url);
  // }

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
