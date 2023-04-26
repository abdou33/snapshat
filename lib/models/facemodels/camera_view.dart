import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../../pages/principal_page.dart';
import '../../pages/video_review.dart';
import '../../themes/colors.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.customPaint,
      this.text,
      required this.onImage,
      this.onScreenModeChanged,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  static CameraController? _controller;
  int _cameraIndex = -1;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final bool _allowPicker = true;
  bool _changingCameraLens = false;

  XFile? image; //for caputred image
  XFile? video; //for recording video
  bool is_recording = false;
  bool front_cam = false;

  @override
  void initState() {
    super.initState();

    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

    if (_cameraIndex != -1) {
      _startLiveFeed();
    } else {
      _mode = ScreenMode.gallery;
    }
  }

  @override
  void dispose() {
    _stopLiveFeed(); // 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _liveFeedBody(),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !is_recording
                  ? FloatingActionButton(
                      backgroundColor: pink2,
                      heroTag: "btn1",
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RawMaterialButton(
                                        shape: CircleBorder(),
                                        elevation: 2.0,
                                        fillColor: pink2,
                                        padding: EdgeInsets.all(15.0),
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        onPressed: () {
                                          pickimage(true);
                                        }),
                                    RawMaterialButton(
                                        shape: CircleBorder(),
                                        elevation: 2.0,
                                        fillColor: pink2,
                                        padding: EdgeInsets.all(15.0),
                                        child: Icon(
                                          Icons.videocam,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        onPressed: () {
                                          pickimage(false);
                                        }),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Icon(Icons.folder),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                width: 10,
              ),
              !is_recording
                  ? FloatingActionButton(
                      backgroundColor: pink2,
                      heroTag: "btn2",
                      onPressed: () async {
                        try {
                          if (_controller != null) {
                            //check if contrller is not null
                            if (_controller!.value.isInitialized) {
                              //check if _controller is initialized
                              await _controller?.stopImageStream();
                              image = await _controller!.takePicture(); //capture image
                              setState(() {
                                //update UI
                              });
                            }
                          }
                        } catch (e) {
                          print(e); //show error
                        }
                        take_pic(image);
                      },
                      child: Icon(Icons.camera),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                width: 10,
              ),
              !is_recording
                  ? FloatingActionButton(
                      backgroundColor: pink2,
                      heroTag: "btn3",
                      onPressed: () async {
                        try {
                          if (_controller != null) {
                            //check if contrller is not null
                            if (_controller!.value.isInitialized) {
                              //check if _controller is initialized
                              setState(() {
                                is_recording = true;
                              });
                              await _controller!.prepareForVideoRecording();
                              await _controller!.startVideoRecording();
                              if (is_flashon) {
                                _controller!.setFlashMode(FlashMode.torch);
                              }
                              setState(() {
                                //update UI
                              });
                            }
                          }
                        } catch (e) {
                          print(e); //show error
                        }
                      },
                      child: Icon(Icons.circle),
                    )
                  : Row(
                      children: [
                        FloatingActionButton(
                          backgroundColor: pink2,
                          heroTag: "btn4",
                          onPressed: () async {
                            try {
                              if (_controller != null) {
                                //check if contrller is not null
                                if (_controller!.value.isInitialized) {
                                  //check if _controller is initialized
                                  setState(() {
                                    is_recording = false;
                                  });
                                  await _controller!.setFlashMode(FlashMode.off);
                                  verify_flash();
                                  await _controller?.stopImageStream();
                                  video = await _controller!.stopVideoRecording();
                                  setState(() {
                                    //update UI
                                  });
                                  final route = MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (_) =>
                                        VideoPage(filePath: video!.path),
                                  );
                                  Navigator.push(context, route);
                                }
                              }
                            } catch (e) {
                              print(e); //show error
                            }
                          },
                          child: Icon(Icons.stop),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        !is_paused
                            ? FloatingActionButton(
                                backgroundColor: pink2,
                                heroTag: "btn6",
                                onPressed: () async {
                                  try {
                                    if (_controller != null) {
                                      //check if contrller is not null
                                      if (_controller!.value.isInitialized) {
                                        //check if controller is initialized
                                        setState(() {
                                          is_paused = true;
                                        });
                                        await _controller!.pauseVideoRecording();
                                        setState(() {
                                          //update UI
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    print(e); //show error
                                  }
                                },
                                child: Icon(Icons.pause),
                              )
                            : FloatingActionButton(
                                backgroundColor: pink2,
                                heroTag: "btn6",
                                onPressed: () async {
                                  try {
                                    if (_controller != null) {
                                      //check if contrller is not null
                                      if (_controller!.value.isInitialized) {
                                        //check if controller is initialized
                                        setState(() {
                                          is_paused = false;
                                        });
                                        await _controller!
                                            .resumeVideoRecording();
                                        setState(() {
                                          //update UI
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    print(e); //show error
                                  }
                                },
                                child: Icon(Icons.play_arrow),
                              ),
                      ],
                    ),
              SizedBox(
                width: 10,
              ),
              !is_recording
                  ? FloatingActionButton(
                      backgroundColor: pink2,
                      heroTag: "btn4",
                      onPressed: () async {
                        if (front_cam) {
                          front_cam = false;
                        } else {
                          front_cam = true;
                        }
                        switch_cam();
                      },
                      child: Icon(Icons.flip_camera_android),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: _controller == null ?
              Center(child: CircularProgressIndicator(color: pink2,),) :
                  !_controller!.value.isInitialized && maxZoomLevel != 0 ?
                  Center(child: CircularProgressIndicator(color: Colors.blue,),)
                  : CameraPreview(_controller!),
            ),
          ),
          if (widget.customPaint != null) widget.customPaint!,
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: maxZoomLevel!= 0
                  ? Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: is_flashon
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          is_flashon = false;
                                        });
                                        _controller!.setFlashMode(FlashMode.off);
                                      },
                                      icon: Icon(
                                        Icons.flash_on,
                                        color: Colors.white,
                                        size: 35,
                                      ))
                                  : IconButton(
                                      onPressed: () {
                                        setState(() {
                                          is_flashon = true;
                                        });
                                        _controller!
                                            .setFlashMode(FlashMode.always);
                                      },
                                      icon: Icon(
                                        Icons.flash_off,
                                        color: Colors.white,
                                        size: 35,
                                      )),
                            ),
                            Expanded(
                              child: SizedBox.shrink(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox.shrink(),
                            ),
                            Container(
                              height:
                                  MediaQuery.of(context).size.height * 60 / 100,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                  activeColor: pink2,
                                  value: zoom,
                                  min: 1.0,
                                  max: maxZoomLevel,
                                  divisions: 30,
                                  label: '$zoom',
                                  onChanged: (double newValue) {
                                    setState(() {
                                      zoom = newValue;
                                      change_zoom();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                      color: pink2,
                    )),
            ),
          )
        ],
      ),
    );
  }

  take_pic(img) {
    // print(File(img!.path).toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Camera_page(File(img!.path))),
    );
  }

  pickimage(bool is_image) async {
    XFile? img;
    if (is_image) {
      img = await ImagePicker().pickImage(source: ImageSource.gallery);
      print("before============" + File(img!.path).toString());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Camera_page(File(img!.path))),
      );
    } else if (!is_image) {
      img = await ImagePicker().pickVideo(source: ImageSource.gallery);
      print("before============" + File(img!.path).toString());
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoPage(
                  filePath: img!.path,
                )),
      );
    }
  }
  
  change_zoom() {
    _controller!.setZoomLevel(zoom);
  }

  bool is_flashon = true;
  bool is_paused = false;
  double zoom = 1;

  verify_flash() {
    if (is_flashon) {
      _controller!.setFlashMode(FlashMode.off);
      _controller!.setFlashMode(FlashMode.always);
    } else {
      _controller!.setFlashMode(FlashMode.off);
    }
    print(is_flashon);
  }

  switch_cam() async {
    maxZoomLevel = 0;
    if (!front_cam) {
      _controller = CameraController(cameras[0], ResolutionPreset.medium);

      _controller!.initialize().then((_) async {
        maxZoomLevel = await _controller!.getMaxZoomLevel();
        setState(() {});
        verify_flash();
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else if (front_cam) {
      //cam_direction = CameraLensDirection.back;
      _controller = CameraController(cameras[1], ResolutionPreset.medium);
      _controller!.initialize().then((_) async {
        maxZoomLevel = await _controller!.getMaxZoomLevel();
        verify_flash();
        setState(() {});
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
    setState(() {});
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) async{
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}