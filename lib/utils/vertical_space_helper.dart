import 'package:flutter/material.dart';

class VerticalSpaceHelper extends StatelessWidget {
  final double height;
  const VerticalSpaceHelper({required this.height, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}
