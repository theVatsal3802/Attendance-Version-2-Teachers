import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../utils/vertical_space_helper.dart';
import './auth_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  static const routeName = "/verify";
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer timer = Timer(const Duration(seconds: 0), () {});
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    isEmailVerified = user!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user!.sendEmailVerification();
      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
      setState(() {
        canResendEmail = true;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Something went wrong",
            textScaleFactor: 1,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: "OK",
            textColor: Theme.of(context).colorScheme.onError,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return isEmailVerified
        ? const Home()
        : SafeArea(
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    VerticalSpaceHelper(height: height * 0.2),
                    Image.asset(
                      "assets/images/logo.png",
                      height: 200,
                      width: 200,
                    ),
                    VerticalSpaceHelper(height: height * 0.1),
                    Text(
                      "A Verification Email has been sent to your provided Email ID.",
                      style: Theme.of(context).textTheme.headline6,
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                    ),
                    VerticalSpaceHelper(height: height * 0.02),
                    ElevatedButton(
                      onPressed: canResendEmail ? sendVerificationEmail : null,
                      style: ElevatedButton.styleFrom(),
                      child: const Text(
                        "RESEND EMAIL",
                        textScaleFactor: 1,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut().then(
                          (_) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AuthScreen.routeName,
                              (route) => false,
                            );
                          },
                        );
                      },
                      child: const Text(
                        "CHANGE EMAIL ID",
                        textScaleFactor: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
