import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:mongo_dart/mongo_dart.dart';

import './constants.dart';

class MongoDB {
  static dynamic db,
      collection,
      tempCollection,
      userCollection,
      studentCollection;

  static Future<String> connect() async {
    try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      collection = db.collection(COLLECTIONS);
      tempCollection = db.collection(TEMP_COLLECTIONS);
      userCollection = db.collection(USERS);
      studentCollection = db.collection(STUDENTS);
      return "Success";
    } on SocketException catch (error) {
      await MongoDB.connect();
      return error.toString();
    }
  }

  static Future<String> insert(
      String batch, String subject, Map<String, dynamic> tempData) async {
    try {
      var doc = await collection.findOne(
        where
            .eq(
              "batch",
              batch,
            )
            .eq(
              "subject",
              subject,
            )
            .eq(
              "month",
              DateTime.now().month.toString(),
            )
            .eq(
              "day",
              DateTime.now().day.toString(),
            ),
      );
      if (doc == null) {
        await collection.insertOne(
          {
            "_id": ObjectId(),
            "batch": batch,
            "subject": subject,
            "month": DateTime.now().month.toString(),
            "day": DateTime.now().day.toString(),
            "year": DateTime.now().year.toString(),
            "attendance": [],
          },
        );
      }
      var result = await tempCollection.insertOne(tempData);
      Fluttertoast.showToast(
        msg: "Started Attendance Process",
        toastLength: Toast.LENGTH_SHORT,
      );
      if (result.isSuccess) {
        return "Success";
      }
      return "Failed";
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to start attendance process",
        toastLength: Toast.LENGTH_SHORT,
      );
      return error.toString();
    }
  }

  static Future<String> insertUser(Map<String, dynamic> data) async {
    try {
      final result = await userCollection.insertOne(data);
      if (result.isSuccess) {
        return "Success";
      }
      return "Failed";
    } catch (error) {
      return error.toString();
    }
  }

  static Future<void> delete(int code) async {
    await tempCollection.remove(where.eq("code", code));
  }

  static Future<Map<String, dynamic>?>  getData(
      String batch, String subject, String month, String day) async {
    var data = await collection.findOne(
      where
          .eq(
            "batch",
            batch,
          )
          .eq(
            "subject",
            subject,
          )
          .eq(
            "month",
            month,
          )
          .eq(
            "day",
            day,
          ),
    );
    if (data == null) {
      return null;
    } else {
      return data;
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendance(
      String batch, String subject) async {
    Stream<Map<String, dynamic>> data = await collection.find(
      where
          .eq(
            "batch",
            batch,
          )
          .eq(
            "subject",
            subject,
          ),
    );
    return data.toList();
  }
}
