import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:share/share.dart';
import 'package:snapshat/themes/colors.dart';
import 'dart:math' as math;

import 'corp_image.dart';

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

  //presetFiltersList
  //presetConvolutionFiltersList
  List<Filter> filters1 = presetConvolutionFiltersList;
  List<Filter> filters2 = presetFiltersList;
  List<Filter>? filters;

// I/flutter (15941): false
// I/flutter (15941): File: '/data/user/0/com.example.snapshat/app_flutter/filtered_AddictiveBlue_images - 2023-04-16T150448.688.jpg'

// I/flutter (15941): true
// I/flutter (15941): File: '/data/user/0/com.example.snapshat/app_flutter/filtered_AddictiveBlue_images - 2023-04-16T150448.688.jpg'

  @override
  void initState() {
    // filters1.take(7);
    // filters2.take(7);
    filters = List.from(filters2.take(10))..addAll(filters1.take(10));
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
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          appBarColor: pink2,
          title: Text(""),
          image: image!,
          filters: filters!,
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
      //print(imageFile!.path);
    }
  }

  saveimagetogallery(File img) async {
    print(img);
    // final directory = await getExternalStorageDirectory();
    // print("directory ====:: \t" + directory.toString());
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else if (status.isGranted) {
      final myImagePath = '/storage/emulated/0/BIsnap';
      final myImgDir = await new Directory(myImagePath).create();

      DateTime ketF = new DateTime.now();

      // copy the file to a new path
      final File newImage =
          await img.copy('$myImagePath/image_${ketF.millisecond}.png');
    }
  }

  shareimage(File img) async {
    final directory = await getExternalStorageDirectory();
    final myImagePath = '${directory!.path}/BIsnap';
    Share.shareFiles(['${img.path}/'], text: "${myImagePath}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink2,
        actions: [
          IconButton(
            icon: Icon(Icons.crop),
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CorpImage(imageFile)),
                ).then((result) {
                  setState(() {
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
            },
          ),
        ],
      ),
      body: Container(
        // when is adding text
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: imageFile == null
                  ? Center(
                      child: new Text('No image selected.'),
                    )
                  : Image.file(imageFile!),
            ),
            SizedBox(
              height: 100,
            ),
            Container(
              height: 75,
              color: pink2,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox.shrink(),
                  ),
                  IconButton(
                    color: Colors.white,
                    iconSize: 40,
                    icon: Icon(Icons.send),
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
