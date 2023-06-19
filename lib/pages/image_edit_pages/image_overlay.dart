import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../widgets/edit_image_viewmodel.dart';
import '../../widgets/image_text.dart';

// add image to our image image page

class ImageOverlayEdit extends StatefulWidget {
  const ImageOverlayEdit({Key? key, required this.selectedImage})
      : super(key: key);
  final String selectedImage;

  @override
  _ImageOverlayEditState createState() => _ImageOverlayEditState();
}

class _ImageOverlayEditState extends State<ImageOverlayEdit> {
  ScreenshotController screenshotController = ScreenshotController();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  double imagesize = 20;

  double _xPosition = 5;
  double _yPosition = 5;

// save image and return it to the previous page
  saveToGallery(BuildContext context) {
    screenshotController.capture().then((Uint8List? image) async {
      DateTime ketF = new DateTime.now();
      String imgname = ketF.microsecondsSinceEpoch.toString();
      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image_$imgname.png').create();

      file.writeAsBytesSync(image!.toList());
      print(file);

      Navigator.pop(context, file);
      //saveImage(image!);
    }).catchError((err) => print(err));
  }

// choose an image from gallery
  pickmage() async {
    print("getting image");
    image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

// increase (+) image size
  increaseimagesize() {
    setState(() {
      imagesize += 2;
    });
  }

// decrease (-) image size
  decreaseimagesize() {
    setState(() {
      imagesize -= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: Column(
        children: [
          Screenshot(
            controller: screenshotController,
            child: SafeArea(
              //height: MediaQuery.of(context).size.height * 0.8,
              // ),
              child: Stack(
                children: [
                  _selectedImage,
                  image != null
                      ? Positioned(
                          top: _yPosition,
                          left: _xPosition,
                          child: Draggable(
                            child: Image.file(
                              File(image!.path),
                              width: imagesize,
                            ), // Replace with your image widget
                            feedback: Image.file(
                              File(image!.path),
                              width: imagesize,
                            ), // Replace with your image widget
                            onDraggableCanceled: (velocity, offset) {
                              setState(() {
                                _xPosition = offset.dx;
                                _yPosition = offset.dy;
                              });
                              print("$_xPosition + \t $_yPosition");
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _addnewTextFab,
    );
  }

// the selected image part in the body
  Widget get _selectedImage => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: Image.file(
          File(
            widget.selectedImage,
          ),
          fit: BoxFit.contain,
          //width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height * 0.7 ,
        ),
      );


// floating buttons
  Widget get _addnewTextFab => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              saveToGallery(context);
            },
            backgroundColor: Colors.white,
            tooltip: 'done',
            child: const Icon(
              Icons.done,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              setState(() {
                pickmage();
              });
            },
            backgroundColor: Colors.white,
            tooltip: 'Add New Text',
            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
        ],
      );

//the appbar part
  AppBar get _appBar => AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.black,
              ),
              onPressed: increaseimagesize,
              tooltip: 'Increase font size',
            ),
            IconButton(
              icon: const Icon(
                Icons.remove,
                color: Colors.black,
              ),
              onPressed: decreaseimagesize,
              tooltip: 'Decrease font size',
            ),
            SizedBox(
              width: 20,
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                _yPosition -= 5;
                  
                });
              },
              tooltip: 'Decrease font size',
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                _yPosition += 5;
                  
                });
              },
              tooltip: 'Decrease font size',
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_left,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                _xPosition -= 5;
                  
                });
              },
              tooltip: 'Decrease font size',
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                _xPosition += 5;
                  
                });
              },
              tooltip: 'Decrease font size',
            ),
          ],
        ),
      ));
}
