import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../themes/colors.dart';
import 'edit_video.dart';

// video preview page

class VideoPage extends StatefulWidget {
  final String filePath;

  const VideoPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  late final Future<void> _videoCtrlInitializationFuture;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    _videoPlayerController.play();
    _videoPlayerController.setLooping(true);
    _videoCtrlInitializationFuture = _videoPlayerController.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Preview'),
          elevation: 0,
          backgroundColor: pink2,
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.check),
              onPressed: () {
                _videoPlayerController.pause();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoEditor(
                            file: File(widget.filePath),
                          )),
                );
              },
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Center(
          child: FutureBuilder(
            future: _videoCtrlInitializationFuture,
            builder: (BuildContext context, AsyncSnapshot videoCtrlInitSnap) {
              if (videoCtrlInitSnap.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
  }
}
