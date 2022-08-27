import 'package:flutter/material.dart';
import '../../full_picker.dart';

// ignore: must_be_immutable
class SheetSelect extends StatefulWidget {
  late BuildContext context;
  late ValueSetter<OutputFile> onSelected;
  late ValueSetter<int> onError;
  late bool image;
  late bool video;
  late bool file;
  bool videoCompressor = true;

  SheetSelect(
      {Key? key,
      BuildContext? context,
      ValueSetter<OutputFile>? onSelected,
      ValueSetter<int>? onError,
      bool? videoCompressor,
      required this.modelName,
      bool? image,
      bool? video,
      bool? file})
      : super(key: key) {
    if ((image == null || image == false) && (video == null || video == false) && (file == null || file == false)) {
      image = true;
      video = true;
      file = true;
      videoCompressor = true;
    }

    this.image = image!;
    this.video = video!;
    this.file = file!;

    if (videoCompressor != null) {
      this.videoCompressor = videoCompressor;
    }

    this.context = context!;
    this.onError = onError!;
    this.onSelected = onSelected!;
  }

  final String modelName;

  @override
  _SheetSelectState createState() => _SheetSelectState();
}

class _SheetSelectState extends State<SheetSelect> {
  late List<Widget> mList;
  bool userClose = true;

  @override
  void initState() {
    super.initState();

    mList = <Widget>[];

    if (widget.image) {
      mList.add(newItem(language.image, Icons.image, () async {
        userClose = false;
        executedImagePicker(widget.image, widget.video, widget.file, widget.context, false, widget.onSelected,
            widget.onError, widget.modelName);
      }));
    }
    if (widget.video) {
      mList.add(newItem(language.video, Icons.video_library, () {
        userClose = false;
        executedVideoPicker(widget.image, widget.video, widget.file, widget.context, false, widget.onSelected,
            widget.onError, widget.videoCompressor, widget.modelName);
      }));
    }

    if (widget.file) {
      mList.add(newItem(language.file, Icons.insert_drive_file, () {
        userClose = false;
        // executedFilePicker(
        //     widget.context, false, widget.onSelected, widget.onError, PickerFileType.FILE, widget.modelName);
      }));
    }
  }

  @override
  void dispose() {
    if (userClose) {
      widget.onError.call(1);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        child: Container(
            color: Colors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              topSheet(widget.image, widget.video, widget.file, language.select_file, true, context, widget.onSelected,
                  widget.onError, widget.videoCompressor,
                  modelName: widget.modelName),
              Container(
                child: Wrap(children: mList),
              )
            ])));
  }
}
