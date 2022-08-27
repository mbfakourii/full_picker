import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'dart:io' as io;

import '../../full_picker.dart';

topSheet(bool image, bool video, bool file, String title, bool showAlone, BuildContext context,
    ValueSetter<OutputFile> onSelected, ValueSetter<int> onError, bool videoCompressor,
    {ValueSetter<int>? onBack, required String modelName}) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Padding(
      padding: EdgeInsets.only(top: 5, left: 5),
      child: ClipOval(
        child: Material(
          child: InkWell(
            child: SizedBox(width: 56, height: 56, child: Icon(Icons.arrow_back)),
            onTap: () {
              if (onBack != null) {
                onBack.call(1);
              }
              backArrowButton(context, showAlone, image, video, file, onSelected, onError, videoCompressor, modelName);
            },
          ),
        ),
      ),
    ),
    Flexible(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    Padding(
        padding: EdgeInsets.only(top: 5, right: 5),
        child: Container(
          width: 56,
        )),
  ]);
}

void showSheet(Widget widget, BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return widget;
      });
}

void backArrowButton(BuildContext context, bool showAlone, bool image, bool video, bool file,
    ValueSetter<OutputFile> onSelected, ValueSetter<int> onError, bool? videoCompressor, String modelName) {
  Navigator.of(context).pop();
  if (!showAlone) {
    showSheet(
        SheetSelect(
          context: context,
          onSelected: onSelected,
          onError: onError,
          image: image,
          file: file,
          video: video,
          videoCompressor: videoCompressor,
          modelName: modelName,
        ),
        context);
  }
}

newItem(String title, IconData icon, GestureTapCallback onTap) {
  return Material(
    child: Ink(
      color: Colors.transparent,
      child: new ListTile(
        leading: new Icon(icon),
        title: new Text(title),
        onTap: () => onTap.call(),
      ),
    ),
  );
}

Future<OutputFile?> getFiles(
    {required BuildContext context,
    required FileType fileType,
    required PickerFileType pickerFileType,
    required String firstPartFileName,
    List<String>? allowedExtensions,
    bool allowMultiple = false}) async {
  try {
    await FilePicker.platform.clearTemporaryFiles();
  } catch (e) {
    print(e);
  }
  late BuildContext lateDialogContext;
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(
    allowMultiple: allowMultiple,
    type: fileType,
    allowedExtensions: allowedExtensions,
    onFileLoading: (value) {
      if (value == FilePickerStatus.picking) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            lateDialogContext = context;
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: const Dialog(
                child: SizedBox(
                  height: 20,
                  width: 50,
                  child: Card(
                      child: LinearProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          minHeight: 8)),
                ),
              ),
            );
          },
        );
      } else {
        return null;
      }
    },
  )
      .catchError((error, stackTrace) {
    Fluttertoast.showToast(msg: language.deny_access_permission, toastLength: Toast.LENGTH_SHORT);
  });

  Navigator.pop(context);

  if (kIsWeb) {
    Navigator.pop(lateDialogContext);
  }

  if (result != null) {
    List<Uint8List?> bytes = [];
    List<String?> name = [];

    result.files.forEach((element) {
      name.add(firstPartFileName + "_" + (name.length + 1).toString() +"."+ element.extension!);
      if(element.bytes==null){
        bytes.add(File(element.path!).readAsBytesSync());
      }else {
        bytes.add(element.bytes);
      }
    });

    return OutputFile(bytes, pickerFileType, name);
  } else {
    return null;
  }
}

Future<String> get destinationFile async {
  String directory;
  final String videoName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
  if (Platform.isAndroid) {
    Directory extDir;

    if (io.Platform.isIOS) {
      extDir = await getApplicationDocumentsDirectory();
    } else {
      extDir = (await getExternalStorageDirectory())!;
    }
    String dirPAth = "${extDir.path}/Video";
    await Directory(dirPAth).create(recursive: true);
    return File('$dirPAth/$videoName').path;
  } else {
    final Directory dir = await path.getLibraryDirectory();
    directory = dir.path;
    return File('$directory/$videoName').path;
  }
}

void executedImagePicker(bool image, bool video, bool file, BuildContext context, bool showAlone,
    ValueSetter<OutputFile> onSelected, ValueSetter<int> onError, String modelName) {
  if (!showAlone) Navigator.of(context).pop();
  showSheet(
      SheetImageOrVideo(
          image: image,
          video: video,
          file: file,
          context: context,
          pictureOrVideo: 1,
          showAlone: showAlone,
          onError: onError,
          videoCompressor: true,
          onSelected: onSelected,
          modelName: modelName),
      context);
}

void executedVideoPicker(
  bool image,
  bool video,
  bool file,
  BuildContext context,
  bool showAlone,
  ValueSetter<OutputFile> onSelected,
  ValueSetter<int> onError,
  bool? videoCompressor,
  String modelName,
) {
  if (!showAlone) Navigator.of(context).pop();
  showSheet(
      SheetImageOrVideo(
          image: image,
          video: video,
          file: file,
          context: context,
          pictureOrVideo: 2,
          showAlone: showAlone,
          onError: onError,
          videoCompressor: videoCompressor,
          onSelected: onSelected,
          modelName: modelName),
      context);
}

void executedFilePicker(
    {required BuildContext context,
    required bool showAlone,
    required ValueSetter<OutputFile> onSelected,
    required ValueSetter<int> onError,
    required PickerFileType fileType,
    required String firstPartFileName,
    required bool allowMultiple}) {
  getFiles(
          context: context,
          fileType: FileType.any,
          pickerFileType: fileType,
          firstPartFileName: firstPartFileName,
          allowMultiple: allowMultiple)
      .then((value) => {
            if (value == null) {onError.call(1)} else {onSelected.call(value), Navigator.of(context).pop()}
          });
}
