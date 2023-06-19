import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../widgets/edit_image_viewmodel.dart';
import '../../widgets/image_text.dart';

// add text to image page

class EditImageScreen extends StatefulWidget {
  const EditImageScreen({Key? key, required this.selectedImage})
      : super(key: key);
  final String selectedImage;

  @override
  _EditImageScreenState createState() => _EditImageScreenState();
}

class _EditImageScreenState extends EditImageViewModel {

  // save image to gallery after adding text to image
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              children: [
            Tooltip(
              message: 'White',
              child: GestureDetector(
                  onTap: () => changeTextColor(Colors.white),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                  )),
            ),
            const SizedBox(
              width: 5,
            ),
            Tooltip(
              message: 'Black',
              child: GestureDetector(
                  onTap: () => changeTextColor(Colors.black),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black,
                  )),
            ),
            const SizedBox(
              width: 5,
            ),
            Tooltip(
              message: 'Blue',
              child: GestureDetector(
                  onTap: () => changeTextColor(Colors.blue),
                  child: const CircleAvatar(
                    backgroundColor: Colors.blue,
                  )),
            ),
            const SizedBox(
              width: 5,
            ),
            Tooltip(
              message: 'Yellow',
              child: GestureDetector(
                  onTap: () => changeTextColor(Colors.yellow),
                  child: const CircleAvatar(
                    backgroundColor: Colors.yellow,
                  )),
            ),
            const SizedBox(
              width: 5,
            ),
            Tooltip(
              message: 'Green',
              child: GestureDetector(
                  onTap: () => changeTextColor(Colors.green),
                  child: const CircleAvatar(
                    backgroundColor: Colors.green,
                  )),
            ),
            const SizedBox(
              width: 5,
            ),
            Tooltip(
              message: 'Orange',
              child: GestureDetector(
                  onTap: () => changeTextColor(Colors.orange),
                  child: const CircleAvatar(
                    backgroundColor: Colors.orange,
                  )),
            ),
            const SizedBox(
              width: 5,
            ),
            Tooltip(
              message: 'Red',
              child: GestureDetector(
                  onTap: () => changeTextColor(Colors.red),
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                  )),
            ),
              ],
            ),
          ),
          Screenshot(
            controller: screenshotController,
            child: SafeArea(
                //height: MediaQuery.of(context).size.height * 0.8,
                  child: Stack(
                    children: [
                      _selectedImage,
                      for (int i = 0; i < texts.length; i++)
                        Positioned(
                          left: texts[i].left,
                          top: texts[i].top,
                          child: GestureDetector(
                            onLongPress: () {
                              setState(() {
                                currentIndex = i;
                                removeText(context);
                              });
                            },
                            onTap: () => setCurrentIndex(context, i),
                            child: Draggable(
                              feedback: ImageText(textInfo: texts[i]),
                              child: ImageText(textInfo: texts[i]),
                              onDragEnd: (drag) {
                                final renderBox =
                                    context.findRenderObject() as RenderBox;
                                Offset off = renderBox.globalToLocal(drag.offset);
                                setState(() {
                                  texts[i].top = off.dy - 96;
                                  texts[i].left = off.dx;
                                });
                              },
                            ),
                          ),
                        ),
                      creatorText.text.isNotEmpty
                          ? Positioned(
                              left: 0,
                              bottom: 0,
                              child: Text(
                                creatorText.text,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(
                                      0.3,
                                    )),
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

  Widget get _selectedImage => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7, 
      maxWidth: MediaQuery.of(context).size.width, 
    ),
    child: Image.file(
            File(
              widget.selectedImage,
            ),
            fit:  BoxFit.contain,
            //width: MediaQuery.of(context).size.width,
            //height: MediaQuery.of(context).size.height * 0.7 ,
          ),
  );

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
            onPressed: () => addNewDialog(context),
            backgroundColor: Colors.white,
            tooltip: 'Add New Text',
            child: const Icon(
              Icons.edit,
              color: Colors.black,
            ),
          ),
        ],
      );

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
              onPressed: increaseFontSize,
              tooltip: 'Increase font size',
            ),
            IconButton(
              icon: const Icon(
                Icons.remove,
                color: Colors.black,
              ),
              onPressed: decreaseFontSize,
              tooltip: 'Decrease font size',
            ),
            IconButton(
              icon: const Icon(
                Icons.format_align_left,
                color: Colors.black,
              ),
              onPressed: alignLeft,
              tooltip: 'Align left',
            ),
            IconButton(
              icon: const Icon(
                Icons.format_align_center,
                color: Colors.black,
              ),
              onPressed: alignCenter,
              tooltip: 'Align Center',
            ),
            IconButton(
              icon: const Icon(
                Icons.format_align_right,
                color: Colors.black,
              ),
              onPressed: alignRight,
              tooltip: 'Align Right',
            ),
            IconButton(
              icon: const Icon(
                Icons.format_bold,
                color: Colors.black,
              ),
              onPressed: boldText,
              tooltip: 'Bold',
            ),
            IconButton(
              icon: const Icon(
                Icons.format_italic,
                color: Colors.black,
              ),
              onPressed: italicText,
              tooltip: 'Italic',
            ),
            IconButton(
              icon: const Icon(
                Icons.space_bar,
                color: Colors.black,
              ),
              onPressed: addLinesToText,
              tooltip: 'Add New Line',
            ),

          ],
        ),
      ));
}
