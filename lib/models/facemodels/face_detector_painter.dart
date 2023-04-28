import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:snapshat/pages/first_page.dart';

import 'cords_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
      this.faces, this.absoluteImageSize, this.rotation, this.image);

  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final ui.Image image;

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;

    for (final Face face in faces) {
      paintImage(
          canvas: canvas,
          scale: 1,
          rect: Rect.fromLTRB(
            translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
            translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
            translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
            translateY(face.boundingBox.bottom, rotation, size, absoluteImageSize),
          ),
          image: image);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}
