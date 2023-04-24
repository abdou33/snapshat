import 'package:flutter/material.dart';
import 'package:snapshat/themes/colors.dart';

import 'pages/principal_page.dart';
import 'pages/first_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Add this
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: pink2,
        ),
      ),
      home: Loginscreen(),
    );
  }
}