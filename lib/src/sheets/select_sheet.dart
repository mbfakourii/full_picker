import 'package:flutter/material.dart';
import '../../full_picker.dart';

// show sheet for select models file picker
class SelectSheet extends StatefulWidget {
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
  final String prefixName;

  const SelectSheet(
      {Key? key,
      required this.videoCompressor,
      required this.prefixName,
      required this.multiFile,
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
  State<SelectSheet> createState() => _SheetSelectState();
}

class _SheetSelectState extends State<SelectSheet> {
  late List<ItemSheet> itemList = [];
  bool userClose = true;

  @override
  void initState() {
    super.initState();

    if (widget.image || widget.video) {
      itemList.add(ItemSheet(globalLanguage.gallery, Icons.image, 1));
    }

    if (widget.imageCamera || widget.videoCamera) {
      itemList.add(ItemSheet(globalLanguage.camera, Icons.camera, 2));
    }

    if (widget.file) {
      itemList.add(ItemSheet(globalLanguage.file, Icons.insert_drive_file, 3));
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
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              topSheet(globalLanguage.selectFile, context),
              GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 2),
                  ),
                  itemCount: itemList.length,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                          customBorder: const CircleBorder(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(itemList[index].icon, size: 30),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(itemList[index].name),
                              )
                            ],
                          ),
                          onTap: () {
                            goPage(itemList[index]);
                          }),
                    );
                  })
            ]));
  }

  // show file picker
  Future<void> goPage(ItemSheet mList) async {
    getFullPicker(
      id: mList.id,
      context: context,
      onIsUserCheng: (value) {
        userClose = value;
      },
      video: widget.video,
      file: widget.file,
      image: widget.image,
      imageCamera: widget.imageCamera,
      videoCamera: widget.videoCamera,
      videoCompressor: widget.videoCompressor,
      onError: widget.onError,
      onSelected: widget.onSelected,
      prefixName: widget.prefixName,
      imageCropper: widget.imageCropper,
      multiFile: widget.multiFile,
      inSheet: true,
    );
  }
}
