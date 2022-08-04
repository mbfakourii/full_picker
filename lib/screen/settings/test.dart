import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(child: Text(":D")),appBar: AppBar(
      title: const Text('dart_vlc'),
      centerTitle: true,
    ),);
  }
}
