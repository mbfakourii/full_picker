import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    print("this is a home");

    return Scaffold(
        appBar: AppBar(
          title: Text(S.current.ahille),
        ),
        body: const Text("home"));
  }
}
