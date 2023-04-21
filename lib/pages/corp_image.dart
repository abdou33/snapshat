import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image/image.dart';
import 'package:image_editor/image_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapshat/themes/colors.dart';

import 'principal_page.dart';

class CorpImage extends StatefulWidget {
  File? image;
  CorpImage(this.image, {super.key});

  @override
  State<CorpImage> createState() => _CorpImageState(this.image);
}

class _CorpImageState extends State<CorpImage> {
  File? imageFile;
  _CorpImageState(this.imageFile);

  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          done_corpping();
          break;
        case 1:
          editorKey.currentState!.flip();
          break;
        case 2:
          editorKey.currentState!.rotate(right: false);
          break;
        case 3:
          editorKey.currentState!.rotate(right: true);
          break;
        case 4:
          editorKey.currentState!.reset();
          break;
        default:
      }
    });
  }

  done_corpping() async {
    ///crop rect base on raw image
    final Rect? cropRect = editorKey.currentState!.getCropRect();

    var data = editorKey.currentState!.rawImageData;

    var action = editorKey.currentState!.editAction;

    final rotateAngle = action!.rotateAngle.toInt();
    final flipHorizontal = action.flipY;
    final flipVertical = action.flipX;
    final img = editorKey.currentState!.rawImageData;

    ImageEditorOption option = ImageEditorOption();

    if (action.needCrop) option.addOption(ClipOption.fromRect(cropRect!));

    if (action.needFlip)
      option.addOption(
          FlipOption(horizontal: flipHorizontal, vertical: flipVertical));

    if (action.hasRotateAngle) option.addOption(RotateOption(rotateAngle));

    final result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    DateTime ketF = new DateTime.now();
    String imgname = ketF.microsecondsSinceEpoch.toString();

    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image_$imgname.png').create();

    file.writeAsBytesSync(result!.toList());
    print(file);

    Navigator.pop(context, file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pink2,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, //New
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,

        showSelectedLabels: true,
        showUnselectedLabels: true,

        unselectedItemColor: pink2,
        selectedItemColor: pink2,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.crop),
            label: 'crop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flip),
            label: 'flip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rotate_left),
            label: 'left',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rotate_right),
            label: 'right',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'reset',
          ),
        ],
      ),
      body: ExtendedImage.file(
        imageFile!,
        fit: BoxFit.contain,
        cacheRawData: true,
        enableSlideOutPage: true,
        mode: ExtendedImageMode.editor,
        extendedImageEditorKey: editorKey,
        initEditorConfigHandler: (state) {
          return EditorConfig(
              lineColor: pink2,
              cornerColor: pink2,
              maxScale: 8.0,
              cropRectPadding: EdgeInsets.all(0.0),
              hitTestSize: 20.0,
              cropAspectRatio: CropAspectRatios.custom);
        },
      ),
    );
  }
}
