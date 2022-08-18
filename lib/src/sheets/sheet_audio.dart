import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../full_picker.dart';

class SheetAudio extends StatefulWidget {
  final bool? showAlone;
  final BuildContext? context;
  final ValueSetter<OutputFile>? onSelected;
  final ValueSetter<int>? onError;
  bool image;
  bool audio;
  bool video;
  bool file;

  SheetAudio(this.image,this.audio,this.video,this.file,
      {Key? key, this.showAlone, this.context, this.onSelected, this.onError})
      : super(key: key);

  @override
  _SheetAudioState createState() => _SheetAudioState();
}

class _SheetAudioState extends State<SheetAudio> {
  bool userClose = true;

  @override
  void dispose() {
    if (userClose) {
      widget.onError!.call(1);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        child: Container(
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  topSheet(widget.image,
                      widget.audio,
                      widget.video,
                      widget.file,
                      language.select_file_method,
                      widget.showAlone!,
                      widget.context!,
                      false,
                      widget.onSelected!,
                      widget.onError!,
                      false),
                  Container(
                    child: new Wrap(
                      children: <Widget>[
                        newItem(language.record_audio, Icons.record_voice_over,
                            () {
                          userClose = false;
                          Navigator.of(context).pop();
                          showSheet(
                              SheetAudioRecorder(widget.image,
                                widget.audio,
                                widget.video,
                                widget.file,
                                context: widget.context!,
                                onError: widget.onError!,
                                onSelected: widget.onSelected!,
                              ),
                              context);
                        }),
                        newItem(language.gallery, Icons.library_music, () {
                          getFile(context, FileType.audio, "AG")
                              .then((value) => {
                                    if (value!.path == '')
                                      {
                                        userClose = false,
                                        widget.onError!.call(1),
                                      }
                                    else
                                      {
                                        userClose = false,
                                        widget.onSelected!.call(OutputFile(
                                            value, PickerFileType.AUDIO)),
                                        Navigator.of(context).pop()
                                      }
                                  });
                        }),
                      ],
                    ),
                  )
                ])));
  }
}
