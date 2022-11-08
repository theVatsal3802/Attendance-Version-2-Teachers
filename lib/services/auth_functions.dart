import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dbHelper/db_connection.dart';

class AuthFunctions {
  String? nameValidator(String name) {
    if (name.isEmpty) {
      return "Please enter your full name";
    }
    return null;
  }

  String? emailValidator(String email) {
    RegExp emailValid = RegExp(r"^[a-z]+\.?[a-z0-9]*@iiitkota.ac.in");
    if (email.isEmpty) {
      return "Please enter your email";
    } else if (!emailValid.hasMatch(email)) {
      return "Invalid teacher email";
    }
    return null;
  }

  String? passwordValidator(String password) {
    RegExp passwordValid = RegExp(r".{8,15}");
    if (password.isEmpty) {
      return "Please enter password";
    } else if (!passwordValid.hasMatch(password)) {
      return "Password must be between 8 and 15 characters long";
    }
    return null;
  }

  Future<bool> submitForm(
    String name,
    String email,
    String password,
    BuildContext context,
    bool isLogin,
  ) async {
    FocusScope.of(context).unfocus();
    try {
      if (isLogin) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final Map<String, dynamic> data = {
          "email": email,
          "name": name,
        };
        await MongoDB.insertUser(data);
      }
      return true;
    } on FirebaseAuthException catch (error) {
      var msg = "An Error Occurred! Please Try Again";
      if (error.code == "invalid-email") {
        msg = "Invalid Email";
      } else if (error.code == "user-not-found") {
        msg = "User Not Found! Please Sign Up to Continue";
      } else if (error.code == "wrong-password") {
        msg = "The password entered by you is invalid";
      } else if (error.code == "email-already-in-use") {
        msg = "The Email entered is already in use! Login with the email";
      }
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text(
              "An Error Occurred",
              textScaleFactor: 1,
            ),
            content: Text(
              msg,
              textScaleFactor: 1,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return false;
    }
  }
}
