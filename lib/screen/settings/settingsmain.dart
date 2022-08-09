
import 'package:ahille/screen/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/language_cubit.dart';
import 'material_example.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    context.read<LanguageCubit>().changeStartLanguage();
    return Scaffold(
      appBar: AppBar(title: const Text("Ahile")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyHomePage2()));
              },
              child: const Text("theme")),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Settings()));
                });
              },
              child: const Text("Setting")),
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   S.of(context).pageHomeListTitle,
                  //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  // ),
                  // const Text(""),
                  // Text(
                  //   S.of(context).pageHomeSamplePlaceholder('John'),
                  //   style: const TextStyle(fontSize: 20),
                  // ),
                  // Text(
                  //   S.of(context).pageHomeSamplePlaceholdersOrdered('John', 'Doe'),
                  //   style: const TextStyle(fontSize: 20),
                  // ),
                  // Text(
                  //   S.of(context).pageHomeSamplePlural(2),
                  //   style: const TextStyle(fontSize: 20),
                  // ),
                  // Text(
                  //   S.of(context).pageHomeSampleTotalAmount(2500.0),
                  //   style: const TextStyle(fontSize: 20),
                  // ),
                  // Text(
                  //   S.of(context).pageHomeSampleCurrentDateTime(DateTime.now(), DateTime.now()),
                  //   style: const TextStyle(fontSize: 20),
                  // ),
                  Text(
                    "currentLanguage\n    $currentLanguage",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    "currentLanguageIsSystemLocal: $currentLanguageIsSystemLocal",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
