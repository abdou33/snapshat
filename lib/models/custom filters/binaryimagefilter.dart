import 'dart:typed_data';
import 'package:photofilters/photofilters.dart';

// binary filter (custom filter)

class BinaryFilter extends Filter {
  int threshold;

  BinaryFilter({required this.threshold, required super.name});

   @override
  void apply(Uint8List pixels, int width, int height) {
    for (int i = 0; i < pixels.length; i += 4) {
      final alpha = pixels[i];
      final red = pixels[i + 1];
      final green = pixels[i + 2];
      final blue = pixels[i + 3];

      final average = (red + green + blue) ~/ 3;
      final binaryValue = average > threshold ? 255 : 0;

      pixels[i] = alpha;
      pixels[i + 1] = binaryValue;
      pixels[i + 2] = binaryValue;
      pixels[i + 3] = binaryValue;
    }
  }
}