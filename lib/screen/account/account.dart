import 'package:flutter/material.dart';

import '../settings/settingsmain.dart';

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
      body: Column(
        children: [
          const Text("Account"),
          MaterialButton(onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyHomePage()));
          },child: Text("settings"),)
        ],
      ),
    );
  }
}
