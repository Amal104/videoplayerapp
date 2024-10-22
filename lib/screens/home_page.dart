import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videoplayerapp/controller/video_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VideoController>(context, listen: false);
    provider.initializeDownload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Prime video",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<VideoController>(
        builder: (context, value, child) {
          return FutureBuilder(
              future: value.getJsonProverb(),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Expanded(
                        flex: 1,
                        child: value.playArea == false
                            ? Container(
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.deepPurple,
                                    Colors.purple,
                                    Color(0xADFFFFFF)
                                  ],
                                )),
                                child: const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Hi watch your favourite\nvideos",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : value.controller!.value.isInitialized && value.controller != null
                                ? Chewie(controller: value.chewieController!)
                                : Container(
                                    decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.deepPurple,
                                        Colors.purple,
                                        Color(0xADFFFFFF)
                                      ],
                                    )),
                                    child: const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Video is loading....",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                    Expanded(
                        flex: 2,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: value.data.length,
                          itemBuilder: (context, index) {
                            final data = value.data[index];
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ListTile(
                                onTap: () {
                                  debugPrint(index.toString());
                                  value.playAreaCheck();
                                  // value.onVideoTap(data["videoUrl"]);
                                  // Play from network if not downloaded, else play from local
                                  if (value.isDownloaded[data["videoUrl"]]!) {
                                    value
                                        .playNetworkVideo(data["videoUrl"]);
                                  } else {
                                    value.playNetworkVideo(
                                        data["videoUrl"]);
                                  }
                                },
                                title: Text(data["title"]),
                                subtitle: Text(data["time"]),
                                leading: Image.network(data["thumbnail"]),
                                trailing: value.isDownloading[data["videoUrl"]]!
                                    ? CircularProgressIndicator(
                                        value: value.downloadProgress[
                                                data["videoUrl"]]! /
                                            100,
                                      )
                                    : value.isDownloaded[data["videoUrl"]]!
                                        ? const Icon(Icons.download_done)
                                        : IconButton(
                                            icon: const Icon(Icons.download),
                                            onPressed: () async {
                                              if (!value.isDownloading[
                                                  data["videoUrl"]]!) {
                                              debugPrint("download pressed");
                                                await value.downloadVideo(
                                                    data["videoUrl"]);
                                              }
                                            },
                                          ),
                              ),
                            );
                          },
                        ))
                  ],
                );
              });
        },
      ),
    );
  }
}
