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
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(
            16.0), // Agrega padding alrededor del contenido
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(
                        8.0), // Agrega padding alrededor del texto
                    child: Text(
                      'Bienvenido al tutorial de TripPlanner. En el siguiente video, aprenderás cómo usar las principales características.',
                      style: TextStyle(
                          fontSize: 20), // Reduce el tamaño de la letra a 20
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    // Hace que el video se expanda para llenar el espacio disponible
                    child: Padding(
                      padding: const EdgeInsets.all(
                          8.0), // Agrega padding alrededor del video
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(
                        8.0), // Agrega padding alrededor del texto
                    child: Text(
                      'Esperamos que este video te sea útil. Si tienes alguna pregunta, no dudes en contactarnos.',
                      style: TextStyle(
                          fontSize: 20), // Reduce el tamaño de la letra a 20
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }
}
