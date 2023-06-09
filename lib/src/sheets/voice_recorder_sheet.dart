import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../full_picker.dart';
import 'package:record/record.dart';
import 'package:http/http.dart';
import 'dart:io' show File;
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// voice recorder sheet
class VoiceRecorderSheet extends StatefulWidget {
  final BuildContext context;
  final String voiceFileName;
  final ValueSetter<FullPickerOutput> onSelected;
  final ValueSetter<int> onError;

  const VoiceRecorderSheet(
      {Key? key,
      required this.context,
      required this.voiceFileName,
      required this.onSelected,
      required this.onError})
      : super(key: key);

  @override
  State<VoiceRecorderSheet> createState() => _SheetSelectState();
}

class _SheetSelectState extends State<VoiceRecorderSheet> {
  bool userClose = true;
  bool started = false;

  int recordTime = 0;

  IconData recordIcon = Icons.keyboard_voice_sharp;

  final Record _record = Record();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  File? lastFile;
  Uint8List? lastUint8List;

  @override
  void initState() {
    super.initState();

    _stopWatchTimer.rawTime.listen((value) {
      setState(() {
        recordTime = value;
      });
    });
  }

  @override
  void dispose() {
    if (userClose) {
      widget.onError.call(1);
    }

    _stopWatchTimer.dispose();
    _record.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StopWatchTimer.getDisplayTime(recordTime),
            style:
                const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10,bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _addButton(Icons.close, () {
                  Navigator.pop(context);
                }, 30, false),
                Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: _addButton(recordIcon, () {
                      if (started) {
                        _pausePlay();
                      } else {
                        _startRecord();
                      }
                    }, 40, true)),
                _addButton(Icons.stop, () async {
                  /// get voice record data
                  await _stopRecord();

                  if (lastUint8List != null) {
                    userClose = false;
                    widget.onSelected.call(FullPickerOutput(
                        [lastUint8List],
                        FullPickerType.voiceRecorder,
                        [widget.voiceFileName],
                        [lastFile]));
                  } else {
                    _showNotStartToast();
                  }
                }, 30, false),
              ],
            ),
          ),
        ]);
  }

  /// add voice record buttons
  _addButton(IconData icon, VoidCallback onPressed, double size,
      bool hasBackgroundColor) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.all(hasBackgroundColor ? 20 : 10),
          elevation: 0,
          foregroundColor: Colors.transparent,
          surfaceTintColor:
              Theme.of(widget.context).colorScheme.onSurface.withAlpha(10),
          backgroundColor: hasBackgroundColor
              ? Theme.of(widget.context).colorScheme.onSurface.withAlpha(50)
              : Theme.of(widget.context).colorScheme.onSurface.withAlpha(10)),
      child: Icon(
        icon,
        color: Theme.of(widget.context).colorScheme.onSurface,
        size: size,
      ),
    );
  }

  /// initialize and start record
  _startRecord() async {
    started = true;
    if (await _record.hasPermission()) {
      _stopWatchTimer.onResetTimer();
      _stopWatchTimer.onStartTimer();
      setState(() {
        recordIcon = Icons.pause;
      });

      _record.start();
    }
  }

  /// stop and return record data
  Future<void> _stopRecord() async {
    if (started == false) return;
    try {
      final value = await _record.stop();
      if (isWeb) {
        final result = await get(Uri.parse(value!));

        lastUint8List = result.bodyBytes;
      } else {
        lastFile = File(value!);

        lastUint8List = File(value).readAsBytesSync();
      }
    } catch (_) {
      return;
    }
  }

  /// resume and pause voice
  Future<void> _pausePlay() async {
    if (await _record.isPaused()) {
      _stopWatchTimer.onStartTimer();

      setState(() {
        recordIcon = Icons.pause;
      });

      _record.resume();
    } else {
      _stopWatchTimer.onStopTimer();

      setState(() {
        recordIcon = Icons.keyboard_voice_sharp;
      });

      _record.pause();
    }
  }

  /// show Not Start Voice Record Toast
  void _showNotStartToast() {
    showFullPickerToast(globalLanguage.noVoiceRecorded, context);
  }
}
