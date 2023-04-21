import 'package:flutter/material.dart';
import 'package:snapshat/themes/colors.dart';

import 'first_page.dart';


class registrationscreen extends StatefulWidget {
  const registrationscreen({Key? key}) : super(key: key);

  @override
  State<registrationscreen> createState() => _registrationscreenState();
}

class _registrationscreenState extends State<registrationscreen> {
  // our form key
  final formkey = GlobalKey<FormState>();
  //editing keys
  final nameeditingcontroller = new TextEditingController();
  final pass1editingcontroller = new TextEditingController();
  final pass2editingcontroller = new TextEditingController();
  var focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    //name field
    final emailField = TextFormField(
      focusNode: focusNode,
      autofocus: false,
      controller: nameeditingcontroller,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please enter a username");
        }
        //reg expression for email validation
        /*if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("this username has already been taken");
        }*/
        return null;
      },
      onSaved: (value) {
        nameeditingcontroller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "username",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    //pass1 field
    final password1Field = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: pass1editingcontroller,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{6,}$');
        //if !password
        if (value!.isEmpty) {
          return ("Password is required");
        }
        //if password < 6
        if (!regex.hasMatch(value)) {
          return ("Enter a password with at least 6 characters");
        }
      },
      onSaved: (value) {
        pass1editingcontroller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    //pass2 field
    final password2Field = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: pass2editingcontroller,
      validator: (value) {
        if (pass2editingcontroller.text != pass1editingcontroller.text) {
          return "password dont match";
        }
        return null;
      },
      onSaved: (value) {
        pass2editingcontroller.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "confirm password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    //submit button
    final signupbutton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: pink2,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          //String newemail = "";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CAM()),
          );
        },
        child: Text(
          "SignUp",
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: pink2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
                child: Container(
              color: pinkywhite,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 250,
                          child: Image.asset(
                            "assets/logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        emailField,
                        SizedBox(
                          height: 20,
                        ),
                        password1Field,
                        SizedBox(
                          height: 20,
                        ),
                        password2Field,
                        SizedBox(
                          height: 35,
                        ),
                        //loginbutton,
                        signupbutton,
                      ],
                    )),
              ),
            )),
          )),
    );
  }

}