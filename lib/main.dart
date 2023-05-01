import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:snapshat/themes/colors.dart';
import 'pages/start_page.dart';

// first page to be excuted

List<CameraDescription> cameras = []; // load available cameras
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // prepare flutter widgets
  cameras = await availableCameras(); // prepare cameras
  runApp(const MyApp());  // run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: pink2,
        ),
      ),
      home: Startscreen(),  // redirect to start screen
    );
  }
}