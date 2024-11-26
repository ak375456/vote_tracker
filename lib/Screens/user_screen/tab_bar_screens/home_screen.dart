import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late VideoPlayerController _controller3;
  late VideoPlayerController _controller4;

  @override
  void initState() {
    super.initState();
    // Initialize each controller
    _controller1 = VideoPlayerController.asset("assets/video/video_1.mp4")
      ..initialize().then((_) {
        setState(() {}); // Rebuild UI when initialized
      });
    _controller2 = VideoPlayerController.asset("assets/video/video_2.mp4")
      ..initialize().then((_) {
        setState(() {});
      });
    _controller3 = VideoPlayerController.asset("assets/video/video_3.mp4")
      ..initialize().then((_) {
        setState(() {});
      });
    _controller4 = VideoPlayerController.asset("assets/video/video_4.mp4")
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  Widget buildVideoPlayer(VideoPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5),
          borderRadius: BorderRadius.circular(
            15.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16.h,
            ),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Image(
                      image: AssetImage("assets/ary.png"),
                    ),
                  ),
                  SizedBox(
                    width: 16.w,
                  ),
                  const Text("ARY NEWS")
                ],
              ),
            ),
            SizedBox(
              height: 24.h,
            ),
            Center(
              child: SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width * 0.9,
                child: controller.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Video Player
                          VideoPlayer(controller),
                          // Play/Pause Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                controller.value.isPlaying
                                    ? controller.pause()
                                    : controller.play();
                              });
                            },
                            child: AnimatedOpacity(
                              opacity: controller.value.isPlaying ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 80.0,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
            // Progress Bar
            // if (controller.value.isInitialized)
            // VideoProgressIndicator(
            //   controller,
            //   allowScrubbing: true,
            //   colors: const VideoProgressColors(
            //     playedColor: Colors.red,
            //     bufferedColor: Colors.grey,
            //   ),
            // ),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title"),
                  Text("Subtitle", style: TextStyle(color: Colors.grey))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context, listen: false);
    log("Home Screen");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Votify"),
          centerTitle: true,
          leading: const Icon(Icons.notifications_none),
          actions: [
            IconButton(
              onPressed: () {
                authServices.signOut(context);
              },
              icon: const Icon(
                Icons.logout,
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            buildVideoPlayer(_controller1),
            buildVideoPlayer(_controller2),
            buildVideoPlayer(_controller3),
            buildVideoPlayer(_controller4),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          splashColor: Colors.transparent,
          onPressed: () {
            showModalBottomSheet<void>(
                isDismissible: true,
                isScrollControlled: true,
                useSafeArea: true,
                showDragHandle: true,
                context: context,
                builder: (BuildContext context) {
                  return Container(
                      constraints: const BoxConstraints(
                        minWidth: double.infinity,
                        minHeight: double.infinity,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: aiScreen());
                });
          },
          child: SvgPicture.asset("assets/fab1.svg"),
        ),
      ),
    );
  }
}

Widget aiScreen() {
  return Column(
    children: [
      AppBar(
        title: const Text(
          "Votify",
          style: TextStyle(color: Colors.grey),
        ),
        centerTitle: true,
      ),
    ],
  );
}
