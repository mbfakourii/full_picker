import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    print("this is a Search");

    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: const Text("Search"),
    );
  }
}
