import 'package:flutter/material.dart';

import '../utils/horizontal_space_helper.dart';

class ListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  const ListItem(this.data, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Row(
          children: [
            const Icon(
              Icons.person,
            ),
            const HorizontalSpaceHelper(width: 10),
            Text(
              "${data["attendance"][index]}",
              textScaleFactor: 1,
            )
          ],
        ),
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.check),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }
}
