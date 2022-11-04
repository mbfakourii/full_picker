import 'package:flutter/material.dart';
import 'package:full_picker/full_picker.dart';
import 'package:full_picker_example/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: Colors.black,
            ),
      ),
      home: const FilePickerTest(),
    );
  }
}

class FilePickerTest extends StatefulWidget {
  const FilePickerTest({Key? key}) : super(key: key);

  @override
  _ExonFilePicker createState() => _ExonFilePicker();
}

class _ExonFilePicker extends State<FilePickerTest> {
  ValueNotifier<double> onProgress = ValueNotifier<double>(0);

  String info = "Not Selected !";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Full Picker Example')),
      body: Column(
        children: [
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Open Full Picker",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
              onPressed: () {
                FullPicker(
                  context: context,
                  prefixName: "test",
                  file: true,
                  voiceRecorder: true,
                  image: true,
                  video: true,
                  videoCamera: true,
                  imageCamera: true,
                  videoCompressor: false,
                  imageCropper: false,
                  multiFile: true,
                  url: true,
                  onError: (int value) {
                    print(" ----  onError ----=$value");
                  },
                  onSelected: (value) {
                    print(" ----  onSelected ----");

                    if (value.fileType != FullPickerType.url) {
                      info = "";
                      for (int i = 0; i < value.name.length; i++) {
                        info +=
                            "File Type :${value.fileType}\nPath File :${value.name[i]}\nSize File :${fileSize(value.bytes[i])}\n--------\n";
                      }
                    } else {
                      info = value.data;
                    }

                    setState(() {});
                  },
                );
              }),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  children: [
                    Text(
                      "Output :\n\n$info",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
