import 'package:flutter/material.dart';
import 'package:snapshat/themes/colors.dart';

import 'first_page.dart';
import 'signup_page.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key}) : super(key: key);

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  // form key
  final formkey = GlobalKey<FormState>();
  //editing controller
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    //email field
    final emailField = TextFormField(
      autofocus: false,
      controller: usernameController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please enter a username");
        }
        //reg expression for username validation
        /*if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("this username is already taken");
        }*/
        return null;
      },
      onSaved: (value) {
        usernameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixStyle: TextStyle(
          color: pink2
        ),
        focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: pink2,
                  ),
                ),
          prefixIcon: Icon(Icons.person),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "username",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );
    //pass field
    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{6,}$');
        //if !password
        if (value!.isEmpty) {
          return ("Password is required for login");
        }
        //if password < 6
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password(Min. 6 Character)");
        }
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixStyle: TextStyle(
          color: pink2
        ),
        focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: pink2,
                  ),
                ),
          prefixIcon: Icon(Icons.lock),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );
    //submit button
    final loginbutton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: pink2,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CAM()),
          );
        },
        child: Text(
          "login",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

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
                        startbutton
                        // emailField,
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // passwordField,
                        // SizedBox(
                        //   height: 35,
                        // ),
                        // loginbutton,
                        // SizedBox(
                        //   height: 15,
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text('Dont have an account?, '),
                        //     GestureDetector(
                        //       onTap: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) =>
                        //                   registrationscreen()),
                        //         );
                        //       },
                        //       child: Text(
                        //         'SignUp',
                        //         style: TextStyle(
                        //             color: pink2,
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 15),
                        //       ),
                        //     )
                        //   ],
                        // )
                      ],
                    )),
              ),
            )),
          )),
    );
  }
}
