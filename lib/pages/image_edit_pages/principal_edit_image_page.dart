import 'dart:async';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:share/share.dart';
import 'package:snapshat/themes/colors.dart';
import 'Textedit_page.dart';
import 'corp_image.dart';

class Camera_page extends StatefulWidget {
  File? image;
  Camera_page(this.image);
  @override
  _Camera_pageState createState() => _Camera_pageState(this.image);
}

class _Camera_pageState extends State<Camera_page> {
  File? imageFile;
  _Camera_pageState(this.imageFile);
  late String fileName;

  //presetFiltersList
  //presetConvolutionFiltersList
  List<Filter> filters1 = presetConvolutionFiltersList;
  List<Filter> filters2 = presetFiltersList;
  List<Filter>? filters;

  @override
  void initState() {
    filters = List.from(filters2.take(10))..addAll(filters1.take(10));      // initializing filtres list
    Future.delayed(Duration.zero, () async {
      getImage();
    });
    super.initState();
  }

  // get image and return filtered image if exists

  Future getImage() async {
    fileName = basename(imageFile!.path);
    var image = imageLib.decodeImage(imageFile!.readAsBytesSync());
    image = imageLib.copyResize(image!, width: 600);
    Map imagefile = await Navigator.push(
      this.context,
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          appBarColor: pink2,
          title: Text(""),
          image: image!,
          filters: filters!,
          filename: fileName,
          loader: Center(
              child: CircularProgressIndicator(
            color: pink2,
          )),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
      });
      //print(imageFile!.path);
    }
  }

  // save image to gallery
  saveimagetogallery(File img) async {
    var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_PICTURES);

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else if (status.isGranted) {
      final myImagePath = '$path/BIsnap';
      await new Directory(myImagePath).create();

      DateTime ketF = new DateTime.now();

      // copy the file to a new path
      final File newImage = await img
          .copy('$myImagePath/image_${ketF.microsecondsSinceEpoch}.png');
    }
  }

  //share image
  shareimage(File img) async {
    final directory = await getExternalStorageDirectory();
    final myImagePath = '${directory!.path}/BIsnap';
    Share.shareFiles(['${img.path}/'], text: "${myImagePath}");
  }
  
  // build widgets (the interface)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink2,
        actions: [
          IconButton(
            icon: Icon(Icons.text_fields),
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => EditImageScreen(
                    selectedImage: imageFile!.path,
                  ),
                ),
              )
                  .then((result) {
                setState(() {
                  print("result: $result");
                  imageFile = result;
                });
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.crop),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CorpImage(imageFile)),
              ).then((result) {
                setState(() {
                  print("result: $result");
                  imageFile = result;
                });
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              shareimage(imageFile!);
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              saveimagetogallery(imageFile!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image saved to gallery.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        // when is adding text
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: imageFile == null
                    ? Center(
                        child: new Text('No image selected.'),
                      )
                    : Image.file(imageFile!, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
