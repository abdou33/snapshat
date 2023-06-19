import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;

import '../models/facemodels/face_detector_painter.dart';
import '../widgets/camera_view.dart';

// first page (choose or take an image or a video)

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

ui.Image? iMage;
String? iMage_name;
bool isfaceon = false;

class _HomeState extends State<Home> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;

  @override
  void initState() {
    load_image();   // load image at first
    super.initState();
  }

// load the image
  load_image() async {
    var bytes = await rootBundle.load("assets/face_filters/transparent.png");
    iMage = await decodeImageFromList(bytes.buffer.asUint8List());
    iMage_name = "assets/face_filters/transparent.png";
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

// process the current frame to detect faces
  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      //print(faces);
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation,
          iMage!);
      _customPaint = CustomPaint(painter: painter);
    } else {
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
          onImage: (inputImage) {
            processImage(inputImage);
          },
        ),
      ),
    );
  }
}
