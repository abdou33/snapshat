import 'package:flutter/material.dart';
import 'package:snapshat/themes/colors.dart';
import 'first_page.dart';

// first start page

class Startscreen extends StatefulWidget {
  const Startscreen({Key? key}) : super(key: key);

  @override
  State<Startscreen> createState() => _StartscreenState();
}

class _StartscreenState extends State<Startscreen> {
  // form key
  final formkey = GlobalKey<FormState>();
  //editing controller
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    // the start button
    final startbutton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      color: pink2,
      child: MaterialButton(
        height: 60,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width/1.5,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CAM()),
          );
        },
        child: Text(
          "Start",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    Future<bool> _onWillPop() async {
      return false; //<-- SEE HERE
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: pinkywhite,
          body: Center(
            child: SingleChildScrollView(
                child: Container(
              color: pinkywhite,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 250,
                          child: Image.asset(
                            "assets/logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        startbutton // click button to start
                      ],
                    )),
              ),
            )),
          )),
    );
  }
}
