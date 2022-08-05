import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    print("this is a chat");

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: const Text("Chat"),
    );
  }
}
