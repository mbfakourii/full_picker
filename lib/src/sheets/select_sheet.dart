import 'package:flutter/material.dart';
import 'package:full_picker/full_picker.dart';

/// show sheet for select models file picker
class SelectSheet extends StatefulWidget {
  const SelectSheet({
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
    required this.voiceRecorder,
    required this.url,
    required this.bodyTextUrl,
    required this.file,
    super.key,
  });
  final BuildContext context;
  final ValueSetter<FullPickerOutput> onSelected;
  final ValueSetter<int>? onError;
  final bool image;
  final bool video;
  final bool file;
  final bool voiceRecorder;
  final bool url;
  final bool imageCamera;
  final bool videoCamera;
  final bool videoCompressor;
  final bool imageCropper;
  final bool multiFile;
  final String bodyTextUrl;
  final String prefixName;

  @override
  State<SelectSheet> createState() => _SheetSelectState();
}

class _SheetSelectState extends State<SelectSheet> {
  late List<ItemSheet> itemList = <ItemSheet>[];
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

    if (widget.voiceRecorder) {
      itemList.add(
        ItemSheet(globalLanguage.voiceRecorder, Icons.keyboard_voice_sharp, 4),
      );
    }
    if (widget.url) {
      itemList.add(ItemSheet(globalLanguage.url, Icons.add_link_sharp, 5));
    }

    switch (itemList.length) {
      case 1:
        crossAxisCount = 1;
        childAspectRatio = 6;
        break;
      case 2:
        crossAxisCount = 2;
        childAspectRatio = 3;
        break;

      default:
        crossAxisCount = 3;
        childAspectRatio = 2;
    }
  }

  @override
  void dispose() {
    if (userClose) {
      widget.onError?.call(1);
    }

    super.dispose();
  }

  double childAspectRatio = 2;
  int crossAxisCount = 2;

  @override
  Widget build(final BuildContext context) => GridView.builder(
        padding: const EdgeInsets.only(bottom: 22),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / childAspectRatio),
        ),
        itemCount: itemList.length,
        itemBuilder: (final BuildContext context, final int index) => Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(itemList[index].icon, size: 30),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(itemList[index].name),
                ),
              ],
            ),
            onTap: () {
              goPage(itemList[index]);
            },
          ),
        ),
      );

  /// show file picker
  Future<void> goPage(final ItemSheet mList) async {
    await getFullPicker(
      id: mList.id,
      context: context,
      onIsUserChange: (final bool value) {
        userClose = value;
      },
      video: widget.video,
      file: widget.file,
      voiceRecorder: widget.voiceRecorder,
      url: widget.url,
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
      bodyTextUrl: widget.bodyTextUrl,
    );
  }
}
