import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/heading_text.dart';
import '../utils/vertical_space_helper.dart';
import '../services/other_functions.dart';
import '../dbHelper/db_connection.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StreamSubscription subscription;
  bool isConnected = false;
  bool isAlertSet = false;
  final _batchContorller = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getConnectivity();
  }

  void showDialogBox() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "No Connection",
            textScaleFactor: 1,
          ),
          content: Image.asset(
            "assets/images/noNet.gif",
            height: 100,
            width: 200,
            fit: BoxFit.contain,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  isAlertSet = false;
                });
                isConnected = await InternetConnectionChecker().hasConnection;
                if (!isConnected) {
                  showDialogBox();
                  setState(() {
                    isAlertSet = true;
                  });
                }
              },
              child: const Text(
                "OK",
                textScaleFactor: 1,
              ),
            ),
          ],
        );
      },
    );
  }

  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (result) async {
        isConnected = await InternetConnectionChecker().hasConnection;
        if (!isConnected && isAlertSet == false) {
          showDialogBox();
          setState(() {
            isAlertSet = true;
          });
        }
        if (isConnected && isAlertSet == true) {
          await MongoDB.connect();
          Fluttertoast.showToast(
            msg: "Connected Again!",
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    subscription.cancel();
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;
  bool isPressed = false;
  bool success = false;
  int? code;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: isPressed ? null : const CustomDrawer(),
        appBar: AppBar(
          title: const Text(
            "Take Attendance",
            textScaleFactor: 1,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                const HeadingText(
                  text: "Subject",
                  textAlign: TextAlign.start,
                ),
                const VerticalSpaceHelper(height: 5),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  enableSuggestions: true,
                  autocorrect: true,
                  key: const ValueKey("subject"),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    hintText: "Eg: CST101, etc.",
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  controller: _subjectController,
                  validator: (value) {
                    RegExp subjectValid = RegExp(
                      r"^[A-Z]{3}[0-9]{3}$",
                      caseSensitive: true,
                    );
                    value = value!.trim().toUpperCase();
                    if (value.isEmpty) {
                      return "Please enter 6 digit subject code";
                    } else if (!subjectValid.hasMatch(value)) {
                      return "Subject Code must have exactly 3 letters and 3 numbers";
                    }
                    return null;
                  },
                ),
                const VerticalSpaceHelper(height: 20),
                const HeadingText(
                  text: "Batch",
                  textAlign: TextAlign.start,
                ),
                const VerticalSpaceHelper(height: 5),
                TextFormField(
                  controller: _batchContorller,
                  textCapitalization: TextCapitalization.characters,
                  enableSuggestions: true,
                  autocorrect: true,
                  key: const ValueKey("batch"),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    hintText: "Eg: CSE2020 for the CSE Batch of 2020",
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    RegExp subjectValid = RegExp(
                      r"^[A-Z]{3}[0-9]{4}$",
                      caseSensitive: true,
                    );
                    value = value!.trim().toUpperCase();
                    if (value.isEmpty) {
                      return "Please enter 7 digit batch code";
                    } else if (!subjectValid.hasMatch(value)) {
                      return "Batch Code must have exactly 3 letters and 4 numbers";
                    }
                    return null;
                  },
                ),
                const VerticalSpaceHelper(height: 30),
                if (isLoading)
                  const Center(child: CircularProgressIndicator.adaptive()),
                if (!isLoading && !isPressed)
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        code = Functions().generateCode();
                        isLoading = true;
                      });
                      try {
                        int res = await Functions().takeAttendance(
                          batch: _batchContorller.text.trim().toUpperCase(),
                          subject: _subjectController.text.trim().toUpperCase(),
                          context: context,
                          formkey: _formKey,
                          code: code!,
                        );
                        setState(() {
                          if (res == -1) {
                            isPressed = false;
                          } else {
                            isPressed = true;
                            success = true;
                          }
                        });
                      } catch (e) {
                        setState(() {
                          success = false;
                          isPressed = false;
                        });
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: const Text(
                      "Generate Attendance Code",
                      textScaleFactor: 1,
                    ),
                  ),
                if (isPressed &&
                    success &&
                    _batchContorller.text.isNotEmpty &&
                    _subjectController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const HeadingText(
                      text: "The Attendance Code is:",
                      textAlign: TextAlign.start,
                    ),
                  ),
                const VerticalSpaceHelper(height: 30),
                if (isPressed &&
                    success &&
                    _batchContorller.text.isNotEmpty &&
                    _subjectController.text.isNotEmpty)
                  Text(
                    "${code!}",
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                const VerticalSpaceHelper(height: 30),
                if (isPressed &&
                    success &&
                    _batchContorller.text.isNotEmpty &&
                    _subjectController.text.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      _batchContorller.clear();
                      _subjectController.clear();
                      await Functions().completeAttendance(context, code!);
                      setState(() {
                        isLoading = false;
                        isPressed = false;
                      });
                    },
                    icon: const Icon(Icons.check),
                    label: const Text(
                      "Complete Attendance",
                      textScaleFactor: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
