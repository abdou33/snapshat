import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../themes/colors.dart';

class VedAccelerator extends StatefulWidget {
  File? ved;
  VedAccelerator({this.ved});
  @override
  _VedAcceleratorState createState() => _VedAcceleratorState();
}

class _VedAcceleratorState extends State<VedAccelerator> {
  double speed = 1;
  VideoPlayerController? _controller;

  @override
  initState() {
    print("file22==: ${widget.ved}");
    if (widget.ved != null) {
      _controller = VideoPlayerController.file(widget.ved!)
        ..initialize().then((_) {
          _controller!.setLooping(true);
          _controller!.play();
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink2,
        actions: [
          IconButton(
              onPressed: () {
                print(_controller!.dataSource);
                //savevedtogallery(File(_controller!.));
                Navigator.pop(context);
              },
              icon: Icon(Icons.done))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _controller != null
              ? Center(
                  child: _controller!.value.isInitialized
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height / 2,
                          ),
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : Container(),
                )
              : CircularProgressIndicator(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (speed > 0.25) {
                    speed = speed - 0.25;
                  }
                  setState(() {
                    _controller!.setPlaybackSpeed(speed);
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(pink2)),
                child: Text(
                  "-",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('$speed'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (speed < 5) {
                    speed = speed + 0.25;
                  }
                  setState(() {
                    _controller!.setPlaybackSpeed(speed);
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(pink2)),
                child: Text(
                  "+",
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
