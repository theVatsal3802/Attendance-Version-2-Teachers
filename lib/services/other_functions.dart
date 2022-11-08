import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../widgets/images.dart';
import '../dbHelper/db_connection.dart';

class Functions {
  Future<DateTime?> setDate(BuildContext context, [DateTime? date]) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      confirmText: "OK",
      cancelText: "Cancel",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (date == null) {
      return null;
    }
    return date;
  }

  Future<bool> dateValidator(BuildContext context, String? date) async {
    if (date != null) {
      if (date.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "No Date Selected",
                textScaleFactor: 1,
              ),
              content: const ErrorGif(),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "OK",
                  ),
                ),
              ],
            );
          },
        );
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> seeRecords(BuildContext context, GlobalKey<FormState> formkey,
      String batch, String subject, DateTime? date) async {
    FocusScope.of(context).unfocus();
    bool dateValid = await dateValidator(context, date.toString());
    bool valid = formkey.currentState!.validate();
    if (!valid && !dateValid) {
      return;
    }
    formkey.currentState!.save();
    var result = await MongoDB.getData(
      batch,
      subject,
      date!.month.toString(),
      date.day.toString(),
    );
    // return result;
  }

  // Future<void> seeRecords(BuildContext context, GlobalKey<FormState> formkey,
  //     String batch, String subject, DateTime? date) async {
  //   FocusScope.of(context).unfocus();
  //   bool dateValid = await dateValidator(context, date.toString());
  //   bool valid = formkey.currentState!.validate();
  //   if (!valid || !dateValid) {
  //     return;
  //   }
  //   formkey.currentState!.save();
    
  // }

  Future<Map<String, dynamic>?> getData(
      String batch, String subject, String month, String day) async {
    final Map<String, dynamic>? data =
        await MongoDB.getData(batch, subject, month, day);
    return data;
  }

  int generateCode() {
    DateTime code = DateTime.now();
    int otp = int.parse("${code.millisecond}${code.microsecond}");
    return otp;
  }

  Future<String> _determinePosition() async {
    String currentAddress = "";
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please Enable your device location service");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location Permission is denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location Permission is denied forever");
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    try {
      currentAddress =
          "${(position.latitude * 1000).ceil()}, ${(position.longitude * 1000).ceil()}";
      return currentAddress;
    } catch (error) {
      Fluttertoast.showToast(msg: "Failed to get current location");
      return "No Location Available";
    }
  }

  Future<int> takeAttendance(
      {required String batch,
      required String subject,
      required BuildContext context,
      required GlobalKey<FormState> formkey,
      required int code}) async {
    FocusScope.of(context).unfocus();
    bool valid = formkey.currentState!.validate();
    if (!valid) {
      return -1;
    }
    formkey.currentState!.save();
    FocusScope.of(context).unfocus();
    final location = await _determinePosition();
    final Map<String, dynamic> tempData = {
      "code": code,
      "hour": DateTime.now().hour.toString(),
      "minute": DateTime.now().minute.toString(),
      "location": location,
    };
    await MongoDB.insert(batch, subject, tempData);
    return 0;
  }

  Future<void> completeAttendance(BuildContext context, int code) async {
    FocusScope.of(context).unfocus();
    await MongoDB.delete(code);
  }

  Future<void> generateExcel(
      {required BuildContext context,
      required GlobalKey<FormState> formkey,
      required String subject,
      required String batch}) async {
    FocusScope.of(context).unfocus();
    bool valid = formkey.currentState!.validate();
    if (!valid) {
      return;
    }
    formkey.currentState!.save();
    final result = await MongoDB.getAttendance(batch, subject);
    final Workbook workbook = Workbook();
    final Worksheet worksheet = workbook.worksheets[0];
    List<String> dates = [];
    for (var i = 0; i < result.length; i++) {
      String date =
          result[i]["day"] + "/" + result[i]["month"] + "/" + result[i]["year"];
      dates.add(date);
    }
    for (var i = 0; i < result.length; i++) {
      final List<Object>? list = result[i]["attendance"];
      worksheet.importList(dates, 1, i + 1, true);
      // worksheet.importList(list!, 2, i + 1, true);
      worksheet.autoFitColumn(i + 1);
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName =
        "$path/Attendance_till_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.xlsx";
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}
