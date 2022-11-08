import 'package:flutter/material.dart';

import '../widgets/list_item.dart';
import '../widgets/heading_text.dart';

class SeeRecordsScreen extends StatefulWidget {
  static const routeName = "/see-records";
  const SeeRecordsScreen({Key? key}) : super(key: key);

  @override
  State<SeeRecordsScreen> createState() => _SeeRecordsScreenState();
}

class _SeeRecordsScreenState extends State<SeeRecordsScreen> {
  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            data == null ? "No Attendance Taken on this day" : data["subject"],
            textScaleFactor: 1,
          ),
        ),
        body: data == null
            ? const Center(
                child: HeadingText(
                  text: "No Attendance Taken on this date",
                  textAlign: TextAlign.start,
                ),
              )
            : ListView.builder(
                itemCount: data["attendance"].length,
                itemBuilder: (context, index) {
                  return ListItem(data, index);
                },
              ),
      ),
    );
  }
}
