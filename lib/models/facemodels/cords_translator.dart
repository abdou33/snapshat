import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:helpers/helpers.dart';

double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  //printCyan(rotation.toString() + "\t\t\t\t" + size.toString() + "\t\t\t\t" + absoluteImageSize.toString());
  print(rotation);
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x * size.width / absoluteImageSize.height;

    case InputImageRotation.rotation270deg:
     printCyan(x * size.width / absoluteImageSize.height);
      double tmp =  x * size.width / absoluteImageSize.height;
      // if (tmp > 0) {
      //   return tmp;
      // } else {
      //   return tmp*2;
      // }
      return x * size.width / absoluteImageSize.height;
    //return size.width - x * size.width / absoluteImageSize.height;

    default:
      return x * size.width / absoluteImageSize.width;
  }
}

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
