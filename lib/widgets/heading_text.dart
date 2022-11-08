import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  const HeadingText({required this.text, required this.textAlign, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textScaleFactor: 1,
      style: TextStyle(
        fontSize: Theme.of(context).textTheme.headline5!.fontSize,
        color: Theme.of(context).colorScheme.secondary,
      ),
      softWrap: true,
      textAlign: textAlign,
    );
  }
}
