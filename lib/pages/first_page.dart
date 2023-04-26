import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapshat/themes/colors.dart';

import '../models/facemodels/camera_view.dart';
import '../models/facemodels/face_detector_painter.dart';
import 'principal_page.dart';
import 'video_review.dart';

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

class _HomeState extends State<Home> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  bool Cam_ready = false;

  @override
  void initState() {
    //loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  // loadCamera() async {
  //   cameras = await availableCameras();
  //   print("cameras == $cameras");
  //   if (cameras != null) {
  //     controller = CameraController(cameras![0], ResolutionPreset.medium);

  //     controller!.initialize().then((_) async {
  //       maxzoom = await controller!.getMaxZoomLevel();
  //       setState(() {});
  //       if (!mounted) {
  //         return;
  //       }
  //       setState(() {
  //         Cam_ready = true;
  //       });
  //     });
  //   } else {
  //     print("NO any camera found");
  //   }
  // }

  



  

  
  

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
            height: height,
            child: CameraView(
                        customPaint: _customPaint,
                        text: _text,
                        onImage: (inputImage) {
                          processImage(inputImage);
                        },
                        initialDirection: CameraLensDirection.back,
                      ),
          ),
    );
  }
}
