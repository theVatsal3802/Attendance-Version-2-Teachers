import 'package:flutter/material.dart';

class HorizontalSpaceHelper extends StatelessWidget {
  final double width;
  const HorizontalSpaceHelper({required this.width, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}
