import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:snapshat/themes/colors.dart';

import 'pages/principal_page.dart';
import 'pages/first_page.dart';
import 'pages/login_page.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Add this
  cameras = await availableCameras();
  runApp(const MyApp());
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
      home: Loginscreen(),
    );
  }
}