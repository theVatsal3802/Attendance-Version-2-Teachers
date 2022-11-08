import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const CustomTextfield({required this.icon, required this.child, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      height: 70,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(
            15,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
