import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/language_cubit.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    context.read<LanguageCubit>().changeLanguage(context, languageCode: 'en');
                    Navigator.pop(context);
                  },
                  child: const Text("English")),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    context.read<LanguageCubit>().changeLanguage(context, languageCode: 'de');
                    Navigator.pop(context);
                  },
                  child: const Text("Germany")),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    context.read<LanguageCubit>().changeLanguage(context, languageCode: 'fa');
                    Navigator.pop(context);
                  },
                  child: const Text("Persian")),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    context.read<LanguageCubit>().changeLanguage(context, languageCode: 'ar');
                    Navigator.pop(context);
                  },
                  child: const Text("Arabic")),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    context.read<LanguageCubit>().changeLanguage(context, languageCode: '');
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                  child: const Text("System")),
            ),
          ],
        ));
  }
}
