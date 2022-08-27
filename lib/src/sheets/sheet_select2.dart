import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../full_picker.dart';

class SheetSelect2 extends StatefulWidget {
  final BuildContext context;
  final ValueSetter<OutputFile> onSelected;
  final ValueSetter<int> onError;
  final bool image;
  final bool video;
  final bool file;
  final bool imageCamera;
  final bool videoCamera;
  final bool videoCompressor;
  final bool imageCropper;
  final bool multiFile;
  final bool allowMultiple;
  final String firstPartFileName;

  SheetSelect2(
      {Key? key,
      required this.videoCompressor,
      required this.firstPartFileName,
      required this.multiFile,
      required this.allowMultiple,
      required this.imageCropper,
      required this.context,
      required this.onSelected,
      required this.onError,
      required this.imageCamera,
      required this.videoCamera,
      required this.image,
      required this.video,
      required this.file})
      : super(key: key);

  @override
  _SheetSelectState2 createState() => _SheetSelectState2();
}

class _SheetSelectState2 extends State<SheetSelect2> {
  late List<ItemSheet> itemList = [];
  bool userClose = true;

  @override
  void initState() {
    super.initState();

    if (widget.image || widget.video) {
      itemList.add(ItemSheet(language.gallery, Icons.image, 1));
    }

    if (widget.imageCamera || widget.videoCamera) {
      if(!kIsWeb)
        itemList.add(ItemSheet(language.camera, Icons.camera, 2));
    }

    if (widget.file) {
      itemList.add(ItemSheet(language.file, Icons.insert_drive_file, 3));
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
        child: Container( height: 60.h,
            color: Colors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              topSheet(widget.image, widget.video, widget.file, language.select_file, true, context, widget.onSelected,
                  widget.onError, widget.videoCompressor,
                  modelName: widget.firstPartFileName),
              Container(

                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 2.w,
                        height: 2.h,
                        child: Material(
                            elevation: 4.0,
                            shape: CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.transparent,
                            child: IconButton(
                                iconSize: 5.h,
                                icon: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(itemList[index].icon),
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.h),
                                      child: Text(itemList[index].name),
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  goPage(itemList[index]);
                                })),
                      );
                    }),
              )
            ])));
  }

  Future<void> goPage(ItemSheet mList) async {
    if (mList.id == 1) {
      // gallery

      userClose = false;
      OutputFile? value;

      if (widget.image && widget.video) {
        value = await getFiles(
            context: context,
            fileType: FileType.custom,
            pickerFileType: PickerFileType.MIXED,
            firstPartFileName: widget.firstPartFileName,
            allowedExtensions: ["mp4", "avi", "mkv", "jpg", "jpeg", "png", "bmp"],
            allowMultiple: widget.multiFile);
      } else if (widget.image) {
        value = await getFiles(
            context: context,
            fileType: FileType.image,
            pickerFileType: PickerFileType.IMAGE,
            firstPartFileName: widget.firstPartFileName,
            allowMultiple: widget.multiFile);
      } else if (widget.video) {
        value = await getFiles(
            context: context,
            fileType: FileType.video,
            pickerFileType: PickerFileType.VIDEO,
            firstPartFileName: widget.firstPartFileName,
            allowMultiple: widget.multiFile);
      }

      if (value == null) {
        userClose = false;
        widget.onError.call(1);
      } else {
        if (widget.allowMultiple && widget.imageCropper && widget.image) {
          Cropper(
            context,
            onSelected: (value) {
              userClose = false;
              Navigator.of(widget.context).pop();
              widget.onSelected.call(value);
            },
            onError: (value) {
              userClose = false;
              if (value == 44) {
                Navigator.of(widget.context).pop();
              }
              widget.onError.call(1);
              Navigator.of(context).pop();
            },
            imageName: "value",
          );
        } else {
          userClose = false;
          Navigator.of(widget.context).pop();
          widget.onSelected.call(value);
        }
      }
    } else if (mList.id == 2) {
      // camera
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return Camera(
            isTakeImage: false,
            onSelected: (value) {
              userClose = false;
              Navigator.of(widget.context).pop();
              widget.onSelected.call(value);
            },
            onError: (value) {
              userClose = false;
              Navigator.of(widget.context).pop();
              widget.onError.call(1);
            },
          );
        },
      ));
    } else if (mList.id == 3) {
      // file
      userClose = false;
      executedFilePicker(
          context: widget.context,
          showAlone: false,
          onSelected: widget.onSelected,
          onError: widget.onError,
          fileType: PickerFileType.FILE,
          firstPartFileName: widget.firstPartFileName,
          allowMultiple: widget.allowMultiple);
    }
  }
}
