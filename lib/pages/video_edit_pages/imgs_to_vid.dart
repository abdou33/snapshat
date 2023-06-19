import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../themes/colors.dart';

class Imgssequencetoved extends StatefulWidget {
  final List<XFile> images;
  const Imgssequencetoved({super.key, required this.images});

  @override
  State<Imgssequencetoved> createState() => _ImgssequencetovedState();
}

class _ImgssequencetovedState extends State<Imgssequencetoved> {
  @override
  void initState() {
    createpathsList();
    super.initState();
  }

  List<String> imgs = [];
  createpathsList() {
    for (var img in widget.images) {
      imgs.add(img.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink2,
      ),
      body: imgs.isNotEmpty ? Container(
        child: ListView.builder(
          itemCount: imgs.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                imgs[index],
                style: TextStyle(fontSize: 18.0),
              ),
            );
          },
        ),
      ) : Center(child: CircularProgressIndicator(),),
    );
  }
}
