import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'dart:io' as io;

import '../../full_picker.dart';

topSheet(
    bool image,
    bool audio,
    bool video,
    bool file,
    String title,
    bool showAlone,
    BuildContext context,
    bool audioRecorder,
    ValueSetter<OutputFile> onSelected,
    ValueSetter<int> onError,
    bool videoCompressor,
    {ValueSetter<int>? onBack}) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Padding(
      padding: EdgeInsets.only(top: 5, left: 5),
      child: ClipOval(
        child: Material(
          child: InkWell(
            child:
                SizedBox(width: 56, height: 56, child: Icon(Icons.arrow_back)),
            onTap: () {
              if (onBack != null) {
                onBack.call(1);
              }
              backArrowButton(
                context,
                showAlone,
                audioRecorder,
                image,
                audio,
                video,
                file,
                onSelected,
                onError,
                videoCompressor,
              );
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

void backArrowButton(
    BuildContext context,
    bool showAlone,
    bool audioRecorder,
    bool image,
    bool audio,
    bool video,
    bool file,
    ValueSetter<OutputFile> onSelected,
    ValueSetter<int> onError,
    bool? videoCompressor) {
  Navigator.of(context).pop();
  if (!showAlone) {
    if (audioRecorder) {
      showSheet(
          SheetAudio(image, audio, video, file,
              showAlone: showAlone,
              context: context,
              onError: onError,
              onSelected: onSelected),
          context);
    } else {
      showSheet(
          SheetSelect(
              context: context,
              onSelected: onSelected,
              onError: onError,
              image: image,
              audio: audio,
              file: file,
              video: video,
              videoCompressor: videoCompressor),
          context);
    }
  }
}

newItem(String title, IconData icon, GestureTapCallback onTap) {
  return Material(
    child: Ink(
      color: Colors.transparent,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: new ListTile(
          leading: new Icon(icon),
          title: new Text(title),
          onTap: () => onTap.call(),
        ),
      ),
    ),
  );
}

// AG = Audio Gallery
// IG = Image Gallery
// VG = Video Gallery
// FG = File Gallery
Future<File?> getFile(
    BuildContext contextMain, FileType type, String from) async {
  await FilePicker.platform.clearTemporaryFiles();
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(
    type: type,
    onFileLoading: (value) {
      if (value == FilePickerStatus.picking) {
        showDialog(
          context: contextMain,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: Dialog(
                child: Container(
                  height: 20,
                  width: 50,
                  child: Card(
                      child: LinearProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple),
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
    Fluttertoast.showToast(
        msg: language.deny_access_permission, toastLength: Toast.LENGTH_SHORT);
  });

  Navigator.pop(contextMain);

  if (result != null) {
    return File(result.files.first.path!);
  } else {
    return File("");
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

void executedImagePicker(
    bool image,
    bool audio,
    bool video,
    bool file,
    BuildContext context,
    bool showAlone,
    ValueSetter<OutputFile> onSelected,
    ValueSetter<int> onError) {
  if (!showAlone) Navigator.of(context).pop();
  showSheet(
      SheetImageOrVideo(
          image: image,
          audio: audio,
          video: video,
          file: file,
          context: context,
          pictureOrVideo: 1,
          showAlone: showAlone,
          onError: onError,
          videoCompressor: true,
          onSelected: onSelected),
      context);
}

void executedVideoPicker(
    bool image,
    bool audio,
    bool video,
    bool file,
    BuildContext context,
    bool showAlone,
    ValueSetter<OutputFile> onSelected,
    ValueSetter<int> onError,
    bool? videoCompressor) {
  if (!showAlone) Navigator.of(context).pop();
  showSheet(
      SheetImageOrVideo(
          image: image,
          audio: audio,
          video: video,
          file: file,
          context: context,
          pictureOrVideo: 2,
          showAlone: showAlone,
          onError: onError,
          videoCompressor: videoCompressor,
          onSelected: onSelected),
      context);
}

void executedAudioPicker(
    bool image,
    bool audio,
    bool video,
    bool file,
    BuildContext context,
    bool showAlone,
    ValueSetter<OutputFile> onSelected,
    ValueSetter<int> onError) {
  if (!showAlone) Navigator.of(context).pop();

  showSheet(
      SheetAudio(image, audio, video, file,
          context: context,
          showAlone: showAlone,
          onError: onError,
          onSelected: onSelected),
      context);
}

void executedFilePicker(BuildContext context, bool showAlone,
    ValueSetter<OutputFile> onSelected, ValueSetter<int> onError) {
  getFile(context, FileType.any, "FG").then((value) => {
        if (value!.path == '')
          {onError.call(1)}
        else
          {
            onSelected.call(OutputFile(value, PickerFileType.FILE)),
            Navigator.of(context).pop()
          }
      });
}
