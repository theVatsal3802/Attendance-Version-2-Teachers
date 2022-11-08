import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';
import '../utils/vertical_space_helper.dart';
import '../widgets/heading_text.dart';
import '../services/other_functions.dart';
import './see_records_screen.dart';

class AttendanceRecordScreen extends StatefulWidget {
  static const routeName = "/attendance-record";
  const AttendanceRecordScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? date;
  final _batchContorller = TextEditingController();
  final _subjectController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: const Text(
            "See Attendance Records",
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
                ListTile(
                  tileColor: Colors.grey[200],
                  title: Text(
                    date == null ? "Select Date" : "Selected Date:",
                    textScaleFactor: 1,
                  ),
                  subtitle: Text(
                    date == null
                        ? "No Date selected yet"
                        : "${date!.day}-${date!.month}-${date!.year}",
                    textScaleFactor: 1,
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      date = await Functions().setDate(context);
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.calendar_month_rounded,
                    ),
                  ),
                ),
                const VerticalSpaceHelper(height: 20),
                const HeadingText(
                  text: "Subject",
                  textAlign: TextAlign.start,
                ),
                const VerticalSpaceHelper(height: 5),
                TextFormField(
                  controller: _subjectController,
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
                const VerticalSpaceHelper(height: 20),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                if (!isLoading)
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await Functions()
                          .seeRecords(
                        context,
                        _formKey,
                        _batchContorller.text.trim().toUpperCase(),
                        _subjectController.text.trim().toUpperCase(),
                        date,
                      )
                          .then(
                        (value) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pushNamed(
                            SeeRecordsScreen.routeName,
                            arguments: value,
                          );
                        },
                      );
                    },
                    child: const Text(
                      "See Attendance Record",
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
