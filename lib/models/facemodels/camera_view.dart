import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../main.dart';
import '../../pages/first_page.dart';
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

  XFile? image; //for caputred image
  XFile? video; //for recording video
  bool is_recording = false;

  ScreenshotController screenshotController = ScreenshotController();

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
                width: 5,
              ),
              !is_recording
                  ? FloatingActionButton(
                      backgroundColor: pink2,
                      heroTag: "btn2",
                      onPressed: () async {
                        if (!isfaceon) {
                          try {
                            if (_controller != null) {
                              //check if contrller is not null
                              if (_controller!.value.isInitialized) {
                                //check if _controller is initialized
                                //_stopLiveFeed();
                                await _controller!.stopImageStream();
                                image = await _controller!
                                    .takePicture(); //capture image
                                _startLiveFeed();
                                setState(() {
                                  //update UI
                                });
                              }
                            }
                          } catch (e) {
                            print(e); //show error
                          }
                          take_pic(image);
                        } else {
                          take_ss();
                        }
                      },
                      child: Icon(Icons.camera),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                width: 5,
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
                              await _controller!.stopImageStream();
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
                                  await _controller!
                                      .setFlashMode(FlashMode.off);
                                  verify_flash();
                                  //await _controller?.stopImageStream();
                                  video =
                                      await _controller!.stopVideoRecording();
                                  _startLiveFeed();
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
                          width: 5,
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
                                        await _controller!
                                            .pauseVideoRecording();
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
                width: 5,
              ),
              !is_recording
                  ? FloatingActionButton(
                      backgroundColor: pink2,
                      heroTag: "btn4",
                      onPressed: () async {
                        _switchLiveCamera();
                      },
                      child: Icon(Icons.flip_camera_android),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                width: 5,
              ),
              !is_recording
                  ? Container(
                      padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
                      child: Container(
                          height: 70.0, width: 70.0, child: _offsetPopup()))
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  List face_filters = [
    "assets/face_filters/nothing.png",
    "assets/face_filters/1.png",
    "assets/face_filters/2.png",
    "assets/face_filters/3.png",
    "assets/face_filters/4.png",
    "assets/face_filters/5.png",
  ];

  Widget _offsetPopup() => PopupMenuButton<int>(
      itemBuilder: (context) => [
            PopupMenuItem(
                value: 1,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: GridView.builder(
                      itemCount: face_filters.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (_, int index) {
                        return GestureDetector(
                          onTap: () {
                            load_image(face_filters[index]);
                          },
                          child: Card(
                            color: iMage_name == face_filters[index]
                                ? pink2
                                : Colors.transparent,
                            child: Image.asset(face_filters[index]),
                          ),
                        );
                      }),
                )),
          ],
      icon: Icon(
        Icons.face_retouching_natural_sharp,
        color: pink2,
      ));

  load_image(String img) async {
    setState(() {
      iMage_name = img;
    });
    if (img == "assets/face_filters/nothing.png") {
      isfaceon = false;
      var bytes = await rootBundle.load("assets/face_filters/transparent.png");
      iMage = await decodeImageFromList(bytes.buffer.asUint8List());
    } else {
      isfaceon = true;
      var bytes = await rootBundle.load(img);
      iMage = await decodeImageFromList(bytes.buffer.asUint8List());
    }
    setState(() {});
    print(iMage_name);
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
          //the camera preview
                Transform.scale(
                  scale: scale,
                  child: Center(
                    child: _controller == null
                        ? Center(
                            child: CircularProgressIndicator(
                              color: pink2,
                            ),
                          )
                        : !_controller!.value.isInitialized && maxZoomLevel != 0
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              )
                            : CameraPreview(_controller!),
                  ),
                ),
                //the custom paint
                if (widget.customPaint != null) widget.customPaint!,
          // the UI
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: maxZoomLevel != 0
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
                                        _controller!
                                            .setFlashMode(FlashMode.off);
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
    print(File(img!.path).toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Camera_page(File(img!.path))),
    );
  }

  take_ss() {
    screenshotController.capture().then((Uint8List? image) async {
      DateTime ketF = new DateTime.now();
      String imgname = ketF.microsecondsSinceEpoch.toString();
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image_$imgname.png').create();

      file.writeAsBytesSync(image!.toList());
      print(file);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Camera_page(file)),
      );
    }).catchError((onError) {
      print(onError);
    });
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


  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) async {
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
    await _controller?.stopImageStream();
    await _controller?.dispose();

    _cameraIndex = (_cameraIndex + 1) % cameras.length;

    await _startLiveFeed();

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
