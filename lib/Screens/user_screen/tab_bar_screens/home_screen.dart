import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:vote_tracker/services/api_services/api_services.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';

import '../../../services/api_services/ai_api_model.dart';

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

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = []; // To store chat messages
  Future<ChatGPTAPIModel>? futureBuilder;
  bool isTyping = false;

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

  void sendMessage() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    final userPrompt = _controller.text.trim();

    if (userPrompt.isNotEmpty) {
      setState(() {
        messages.add({'role': 'user', 'content': userPrompt});
        isTyping = true; // Show loading indicator
      });

      _controller.clear(); // Clear the text field immediately

      ChatGptApiService().sendChatGptRequest(userPrompt).then((response) {
        if (!mounted) return; // Check if widget is still mounted
        setState(() {
          messages.add({
            'role': 'ai',
            'content': response.result ?? "No response from AI",
          });
          isTyping = false; // Hide loading indicator
        });
      }).catchError((error) {
        if (!mounted) return; // Check if widget is still mounted
        setState(() {
          messages.add({'role': 'ai', 'content': 'Error: $error'});
          isTyping = false; // Hide loading indicator
        });
      });
    }
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
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text(
                          "Votify",
                          style: TextStyle(color: Colors.grey),
                        ),
                        centerTitle: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: messages.length +
                              (isTyping ? 1 : 0), // Add 1 if typing
                          itemBuilder: (context, index) {
                            if (index == messages.length) {
                              // Show loading indicator at the end
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: Lottie.asset(
                                              "assets/aiani.json")),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "Typing...",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final message = messages[index];
                            final isUser = message['role'] == 'user';

                            return Align(
                              alignment: isUser
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xffD7D7D7)
                                      : const Color(0xff2D8BBA),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.r),
                                    topRight: Radius.circular(12.r),
                                    bottomLeft: isUser
                                        ? const Radius.circular(0)
                                        : Radius.circular(12.r),
                                    bottomRight: isUser
                                        ? Radius.circular(12.r)
                                        : const Radius.circular(0),
                                  ),
                                ),
                                child: Text(
                                  message['content']!,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      futureBuilder == null
                          ? const SizedBox.shrink()
                          : FutureBuilder<ChatGPTAPIModel>(
                              future: futureBuilder,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Failed to fetch response. Please try again.",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                } else {
                                  ChatGPTAPIModel data = snapshot.data!;
                                  log(data.result.toString());

                                  return const SizedBox
                                      .shrink(); // Response will already be in the `messages`
                                }
                              },
                            ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          top: 8.h,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Colors.grey[300]!)),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    hintText: 'How can I help you?',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.send, color: Colors.blue),
                                onPressed: sendMessage,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: SvgPicture.asset("assets/fab1.svg"),
        ),
      ),
    );
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
}
