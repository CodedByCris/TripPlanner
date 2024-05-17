import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/video.mp4')
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Video Tutorial'),
      ),
      body: _controller.value.isInitialized
          ? Expanded(
              child: Chewie(
                controller: _chewieController,
              ),
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }
}
