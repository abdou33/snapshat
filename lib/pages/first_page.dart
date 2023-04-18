import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'cam_page.dart';

class CAM extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
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
      MaterialPageRoute(
          builder: (context) => Camera_page(File(img!.path))),
    );
  }

  pickimage() async {
    XFile? img;
    img = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("before============" + File(img!.path).toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Camera_page(File(img!.path))),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // appBar: AppBar(
      //     title: Text("Live Camera Preview"),
      //     backgroundColor: Colors.redAccent,
      // ),
      body: Container(
        child: Container(
            height: height,
            child: controller == null
                ? Center(child: Text("Loading Camera..."))
                : !controller!.value.isInitialized
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : CameraPreview(controller!)),

        // Container( //show captured image
        //    padding: EdgeInsets.all(30),
        //    child: image == null?
        //          Text("No image captured"):
        //          Image.file(File(image!.path), height: 300,),
        //          //display captured image
        // )
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                pickimage();
              },
              child: Icon(Icons.image),
            ),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () async {
                try {
                  if (controller != null) {
                    //check if contrller is not null
                    if (controller!.value.isInitialized) {
                      //check if controller is initialized
                      image = await controller!.takePicture(); //capture image
                      setState(() {
                        //update UI
                      });
                    }
                  }
                } catch (e) {
                  print(e); //show error
                }
                take_pic(image);
                print("image========");
                print(File(image!.path));
              },
              child: Icon(Icons.camera),
            ),
            SizedBox(
              width: 60,
            )
          ],
        ),
      ),
    );
  }
}
