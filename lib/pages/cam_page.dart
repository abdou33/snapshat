import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';

class Camera_page extends StatefulWidget {
  File? image;
  Camera_page(this.image);
  @override
  _Camera_pageState createState() => new _Camera_pageState(this.image);
}

class _Camera_pageState extends State<Camera_page> {
  File? imageFile;
  _Camera_pageState(this.imageFile);
  late String fileName;
  List<Filter> filters = presetFiltersList;

  @override
  void initState() {
    print(imageFile);
    Future.delayed(Duration.zero, () async {
    getImage();
});
    super.initState();
  }

  Future getImage() async {
    fileName = basename(imageFile!.path);
    var image = imageLib.decodeImage(imageFile!.readAsBytesSync());
    image = imageLib.copyResize(image!, width: 600);
    Map imagefile = await Navigator.push(
      this.context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text("Photo Filter Example"),
          image: image!,
          filters: presetFiltersList,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
      });
      print(imageFile!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Photo Filter Example'),
      ),
      body: Center(
        child: new Container(
          child: imageFile == null
              ? Center(
                  child: new Text('No image selected.'),
                )
              : Image.file(imageFile!),
        ),
      ),
    );
  }
}
