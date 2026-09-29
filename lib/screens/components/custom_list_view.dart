import 'package:flutter/material.dart';

class CustomListView extends StatelessWidget {
  final List<Widget> children;

  const CustomListView({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(children.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < children.length - 1 ? 12 : 0),
            child: children[index],
          );
        }),
      ),
    );
  }
}
