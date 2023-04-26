import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapshat/themes/colors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/facemodels/detector.dart';
import '../models/facemodels/model.dart';
import '../models/facemodels/utils.dart';
import 'principal_page.dart';
import 'video_review.dart';
import 'package:image/image.dart' as imglib;
import 'package:quiver/collection.dart';

class CAM extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for caputred image
  XFile? video; //for recording video
  bool is_recording = false;
  bool front_cam = false;

  @override
  void initState() {
    // loadCamera();
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _start();
  }

  void _start() async {
    interpreter = await loadModel();
    initialCamera();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    if (controller != null) {
      await controller!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      //await controller!.dispose();
      controller = null;
    }
    super.dispose();
  }

  void initialCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.medium);

      controller!.initialize().then((_) async {
        maxzoom = await controller!.getMaxZoomLevel();
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
    await Future.delayed(const Duration(milliseconds: 500));
    loading = false;
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    jsonFile = File(_embPath);
    if (jsonFile.existsSync()) {
      data = json.decode(jsonFile.readAsStringSync());
    }

    await Future.delayed(const Duration(milliseconds: 500));


    if(controller!.value.isInitialized){
      controller!.startImageStream((CameraImage image) async {
      if (controller != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        dynamic finalResult =  Multimap<String, Face>();

        detect(image, getDetectionMethod()).then((dynamic result) async {
          if (result.length == 0 || result == null) {
            _faceFound = false;
            _predRes = 'Tidak dikenali';
          } else {
            _faceFound = true;
          }

          String res;
          Face _face;

          imglib.Image convertedImage =
              convertCameraImage(image, CameraLensDirection.front);

          for (_face in result) {
            double x, y, w, h;
            x = (_face.boundingBox.left - 10);
            y = (_face.boundingBox.top - 10);
            w = (_face.boundingBox.width + 10);
            h = (_face.boundingBox.height + 10);
            imglib.Image croppedImage = imglib.copyCrop(
                convertedImage, x.round(), y.round(), w.round(), h.round());
            croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
            res = recog(croppedImage);
            finalResult.add(res, _face);
          }

          _scanResults = finalResult;
          _isDetecting = false;
          setState(() {});
        }).catchError(
          (_) async {
            print({'error': _.toString()});
            _isDetecting = false;
            if (controller != null) {
              await controller!.stopImageStream();
              await Future.delayed(const Duration(milliseconds: 400));
              await controller!.dispose();
              await Future.delayed(const Duration(milliseconds: 400));
              controller = null;
            }
            Navigator.pop(context);
          },
        );
      }
    });
    }

    
  }

  late File jsonFile;
  var interpreter;
  dynamic data = {};
  bool _isDetecting = false;
  double threshold = 1.0;
  dynamic _scanResults;
  String _predRes = '';
  bool isStream = true;
  CameraImage? controllerimage;
  Directory? tempDir;
  bool _faceFound = false;
  bool _verify = false;
  List? e1;
  bool loading = true;
  final TextEditingController _name = TextEditingController(text: '');

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

  switch_cam() async {
    maxzoom = 0;
    if (!front_cam) {
      controller = CameraController(cameras![0], ResolutionPreset.medium);

      controller!.initialize().then((_) async {
        maxzoom = await controller!.getMaxZoomLevel();
        setState(() {});
        verify_flash();
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else if (front_cam) {
      controller = CameraController(cameras![1], ResolutionPreset.medium);
      controller!.initialize().then((_) async {
        maxzoom = await controller!.getMaxZoomLevel();
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

  double maxzoom = 0;
  change_zoom() {
    controller!.setZoomLevel(zoom);
  }

  bool is_flashon = true;
  bool is_paused = false;
  double zoom = 1;

  verify_flash() {
    if (is_flashon) {
      controller!.setFlashMode(FlashMode.off);
      controller!.setFlashMode(FlashMode.always);
    } else {
      controller!.setFlashMode(FlashMode.off);
    }
    print(is_flashon);
  }

  String recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1!).toUpperCase();
  }

  String compare(List currEmb) {
    //mengembalikan nama pemilik akun
    double minDist = 999;
    double currDist = 0.0;
    _predRes = "Tidak dikenali";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        _predRes = label;
        if (_verify == false) {
          _verify = true;
        }
      }
    }
    return _predRes;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // appBar: AppBar(
      //     title: Text("Live Camera Preview"),
      //     backgroundColor: Colors.transparent,
      // ),
      body: Stack(
        children: [
          Container(
              height: height,
              child: (controller == null || !controller!.value.isInitialized) || loading && maxzoom != 0
                      ? Center(
                          child: CircularProgressIndicator(
                            color: pink2,
                          ),
                        )
                      : Container(
                        constraints: const BoxConstraints.expand(),
                        
                        child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(controller!),
                    _buildResults(),
                  ],
                ),)
                ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: maxzoom != 0
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
                                        controller!.setFlashMode(FlashMode.off);
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
                                        controller!
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
                                  max: maxzoom,
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
                          if (controller != null) {
                            //check if contrller is not null
                            if (controller!.value.isInitialized) {
                              //check if controller is initialized
                              image = await controller!
                                  .takePicture(); //capture image
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
                          if (controller != null) {
                            //check if contrller is not null
                            if (controller!.value.isInitialized) {
                              //check if controller is initialized
                              setState(() {
                                is_recording = true;
                              });
                              await controller!.prepareForVideoRecording();
                              await controller!.startVideoRecording();
                              if (is_flashon) {
                                controller!.setFlashMode(FlashMode.torch);
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
                              if (controller != null) {
                                //check if contrller is not null
                                if (controller!.value.isInitialized) {
                                  //check if controller is initialized
                                  setState(() {
                                    is_recording = false;
                                  });
                                  await controller!.setFlashMode(FlashMode.off);
                                  verify_flash();
                                  video =
                                      await controller!.stopVideoRecording();
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
                                    if (controller != null) {
                                      //check if contrller is not null
                                      if (controller!.value.isInitialized) {
                                        //check if controller is initialized
                                        setState(() {
                                          is_paused = true;
                                        });
                                        await controller!.pauseVideoRecording();
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
                                    if (controller != null) {
                                      //check if contrller is not null
                                      if (controller!.value.isInitialized) {
                                        //check if controller is initialized
                                        setState(() {
                                          is_paused = false;
                                        });
                                        await controller!
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
                      child: Icon(Icons.flip_camera_android_rounded),
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

  Widget _buildResults() {
    Center noResultsText = const Center(
        child: Text('preparing ...',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.white)));
    if (_scanResults == null ||
        controller == null ||
        !controller!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      controller!.value.previewSize!.height,
      controller!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }
}
