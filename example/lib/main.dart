import 'package:flutter/material.dart';
import 'package:full_picker/full_picker.dart';

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
        primarySwatch: Colors.deepPurple,
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
      backgroundColor: Colors.white70,
      appBar: AppBar(title: Text('Full Picker Example')),
      body: Container(
          child: Center(
              child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueGrey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Open Full Picker",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              onPressed: () {
                FullPicker(
                  context: context,
                  prefixName: "test",
                  file: true,
                  image: true,
                  video: true,
                  videoCamera: true,
                  imageCamera: true,
                  videoCompressor: false,
                  imageCropper: false,
                  multiFile: true,
                  onError: (int value) {
                    print(" ----  onError ----=$value");
                  },
                  onSelected: (value) {
                    print(" ----  onSelected ----");

                    info = "";
                    for (int i = 0; i < value.name.length; i++) {
                      info +=
                          "File Type :${value.fileType}\nPath File :${value.name[i]}\nSize File :${fileSize(value.bytes[i])}\n--------\n";
                    }

                    setState(() {});
                  },
                );
              }),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Output :\n\n$info",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          )
        ],
      ))),
    );
  }

  String fileSize(dynamic size, [int round = 2]) {
    /**
     * [size] can be passed as number or as string
     *
     * the optional parameter [round] specifies the number
     * of digits after comma/point (default is 2)
     */
    int divider = 1024;
    int _size;
    try {
      _size = size.length;
    } catch (e) {
      throw ArgumentError("Can not parse the size parameter: $e");
    }

    if (_size < divider) {
      return "$_size B";
    }

    if (_size < divider * divider && _size % divider == 0) {
      return "${(_size / divider).toStringAsFixed(0)} KB";
    }

    if (_size < divider * divider) {
      return "${(_size / divider).toStringAsFixed(round)} KB";
    }

    if (_size < divider * divider * divider && _size % divider == 0) {
      return "${(_size / (divider * divider)).toStringAsFixed(0)} MB";
    }

    if (_size < divider * divider * divider) {
      return "${(_size / divider / divider).toStringAsFixed(round)} MB";
    }

    if (_size < divider * divider * divider * divider && _size % divider == 0) {
      return "${(_size / (divider * divider * divider)).toStringAsFixed(0)} GB";
    }

    if (_size < divider * divider * divider * divider) {
      return "${(_size / divider / divider / divider).toStringAsFixed(round)} GB";
    }

    if (_size < divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} TB";
    }

    if (_size < divider * divider * divider * divider * divider) {
      num r = _size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} TB";
    }

    if (_size < divider * divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} PB";
    } else {
      num r = _size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} PB";
    }
  }
}
