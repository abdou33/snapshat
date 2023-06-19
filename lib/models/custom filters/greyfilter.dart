import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photofilters/filters/filters.dart';

// gray filter (custom filter)

class GrayscaleFilter extends Filter {
  GrayscaleFilter({required super.name});

  @override
  void apply(Uint8List pixels, int width, int height) {
    for (int i = 0; i < pixels.length; i += 4) {
      final red = pixels[i];
      final green = pixels[i + 1];
      final blue = pixels[i + 2];

      final average = ((red + green + blue) / 3).round();

      pixels[i] = average;
      pixels[i + 1] = average;
      pixels[i + 2] = average;
    }
  }
}
