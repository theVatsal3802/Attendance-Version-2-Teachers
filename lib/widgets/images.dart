import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Image.asset(
        "assets/images/logo.png",
        height: 200,
        width: 200,
        alignment: Alignment.center,
        fit: BoxFit.contain,
      ),
    );
  }
}

class ConfirmScreenWidget extends StatelessWidget {
  const ConfirmScreenWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Image.asset(
        "assets/images/confirm.gif",
        height: 200,
        width: 200,
        alignment: Alignment.center,
        fit: BoxFit.contain,
      ),
    );
  }
}

class ErrorGif extends StatelessWidget {
  const ErrorGif({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 200,
      child: Image.asset(
        "assets/images/error.gif",
        height: 100,
        width: 200,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
