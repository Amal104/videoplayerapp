import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Prime video"),
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
                            : value.controller!.value.isInitialized
                                ? Chewie(controller: value.chewieController!)
                                :  Container(
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
                                  value.onVideoTap(data["videoUrl"]);
                                },
                                title: Text(data["title"]),
                                subtitle: Text(data["time"]),
                                leading: Image.network(data["thumbnail"]),
                                trailing: IconButton(
                                    onPressed: () {},
                                    icon: data["isD"] == false
                                        ? const Icon(Icons.download)
                                        : const Icon(Icons.download_done)),
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
