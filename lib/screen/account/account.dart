import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    print("this is a Account");

    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: const Text("Account"),
    );
  }
}
