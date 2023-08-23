import 'package:flutter/material.dart';

import '../../full_picker.dart';

class URLInputDialog extends StatefulWidget {
  const URLInputDialog({super.key, this.text = '', required this.body});
  final String text;
  final String body;
  @override
  State<URLInputDialog> createState() => _URLInputDialogState();
}

class _URLInputDialogState extends State<URLInputDialog> {
  late final TextEditingController textfieldController;
  @override
  void initState() {
    textfieldController = TextEditingController(text: widget.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(globalLanguage.enterURL,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
      contentPadding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width / 2.3,
                  maxWidth: MediaQuery.of(context).size.width),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 5),
                child: Column(
                  children: [
                    TextField(
                      keyboardType: TextInputType.text,
                      textDirection: TextDirection.ltr,
                      autofocus: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 2, right: 2),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Icon(Icons.add_link_sharp),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      controller: textfieldController,
                    ),
                    if (widget.body != '')
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(widget.body),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              globalLanguage.cancel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            )),
        TextButton(
            onPressed: () {
              Navigator.pop(context, textfieldController.text);
            },
            child: Text(
              globalLanguage.ok,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            )),
      ],
    );
  }
}
