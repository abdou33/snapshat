import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapshat/themes/colors.dart';

import 'principal_page.dart';
import 'video_review.dart';

class CAM extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for caputred image
  XFile? video; //for recording video
  bool is_recording = false;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.medium);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  take_pic(img) {
    print(File(img!.path).toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Camera_page(File(img!.path))),
    );
  }

  pickimage(bool is_image) async {
    XFile? img;
    if (is_image) {
      img = await ImagePicker().pickImage(source: ImageSource.gallery);
      print("before============" + File(img!.path).toString());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Camera_page(File(img!.path))),
      );
    } else if (!is_image) {
      img = await ImagePicker().pickVideo(source: ImageSource.gallery);
      print("before============" + File(img!.path).toString());
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoPage(
                  filePath: img!.path,
                )),
      );
    }
  }

  bool is_flashon = true;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // appBar: AppBar(
      //     title: Text("Live Camera Preview"),
      //     backgroundColor: Colors.transparent,
      // ),
      body: Stack(
        children: [
          Container(
              height: height,
              child: controller == null
                  ? Center(child: Text("Loading Camera..."))
                  : !controller!.value.isInitialized
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : CameraPreview(controller!)),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  is_flashon
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              is_flashon = false;
                            });
                            controller!.setFlashMode(FlashMode.off);
                          },
                          icon: Icon(
                            Icons.flash_on,
                            color: Colors.white,
                            size: 35,
                          ))
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              is_flashon = true;
                            });
                            controller!.setFlashMode(FlashMode.always);
                          },
                          icon: Icon(
                            Icons.flash_off,
                            color: Colors.white,
                            size: 35,
                          ))
                ],
              ),
            ),
          )
        ],
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !is_recording
                ? FloatingActionButton(
                    backgroundColor: pink2,
                    heroTag: "btn1",
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RawMaterialButton(
                                      shape: CircleBorder(),
                                      elevation: 2.0,
                                      fillColor: pink2,
                                      padding: EdgeInsets.all(15.0),
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      onPressed: () {
                                        pickimage(true);
                                      }),
                                  RawMaterialButton(
                                      shape: CircleBorder(),
                                      elevation: 2.0,
                                      fillColor: pink2,
                                      padding: EdgeInsets.all(15.0),
                                      child: Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      onPressed: () {
                                        pickimage(false);
                                      }),
                                ],
                              ),
                            );
                          });
                    },
                    child: Icon(Icons.folder),
                  )
                : SizedBox.shrink(),
            !is_recording
                ? FloatingActionButton(
                    backgroundColor: pink2,
                    heroTag: "btn2",
                    onPressed: () async {
                      try {
                        if (controller != null) {
                          //check if contrller is not null
                          if (controller!.value.isInitialized) {
                            //check if controller is initialized
                            image =
                                await controller!.takePicture(); //capture image
                            setState(() {
                              //update UI
                            });
                          }
                        }
                      } catch (e) {
                        print(e); //show error
                      }
                      take_pic(image);
                    },
                    child: Icon(Icons.camera),
                  )
                : SizedBox.shrink(),
            !is_recording
                ? FloatingActionButton(
                    backgroundColor: pink2,
                    heroTag: "btn3",
                    onPressed: () async {
                      try {
                        if (controller != null) {
                          //check if contrller is not null
                          if (controller!.value.isInitialized) {
                            //check if controller is initialized
                            setState(() {
                              is_recording = true;
                            });
                            await controller!.prepareForVideoRecording();
                            await controller!.startVideoRecording();
                            setState(() {
                              //update UI
                            });
                          }
                        }
                      } catch (e) {
                        print(e); //show error
                      }
                    },
                    child: Icon(Icons.circle),
                  )
                : FloatingActionButton(
                    backgroundColor: pink2,
                    heroTag: "btn4",
                    onPressed: () async {
                      try {
                        if (controller != null) {
                          //check if contrller is not null
                          if (controller!.value.isInitialized) {
                            //check if controller is initialized
                            setState(() {
                              is_recording = false;
                            });
                            video = await controller!.stopVideoRecording();
                            print(video!.path);
                            setState(() {
                              //update UI
                            });
                            final route = MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (_) => VideoPage(filePath: video!.path),
                            );
                            Navigator.push(context, route);
                          }
                        }
                      } catch (e) {
                        print(e); //show error
                      }
                    },
                    child: Icon(Icons.stop),
                  ),
            SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
