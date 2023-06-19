import 'dart:ui';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';

// calculate the position of the face and return x and y position in the screen

// calculate and return x position
double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x * size.width / absoluteImageSize.height;

    case InputImageRotation.rotation270deg:
      return x * size.width / absoluteImageSize.height;

    default:
      return x * size.width / absoluteImageSize.width;
  }
}

// calculate and return y position
double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y * size.height / absoluteImageSize.width;

    default:
      return y * size.height / absoluteImageSize.height;
  }
}
