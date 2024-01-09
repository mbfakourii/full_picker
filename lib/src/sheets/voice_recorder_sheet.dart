import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:full_picker/full_picker.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:record/record.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// voice recorder sheet
class VoiceRecorderSheet extends StatefulWidget {
  const VoiceRecorderSheet({
    required this.context,
    required this.voiceFileName,
    required this.onSelected,
    required this.onError,
    super.key,
  });

  final BuildContext context;
  final String voiceFileName;
  final ValueSetter<FullPickerOutput> onSelected;
  final ValueSetter<int> onError;

  @override
  State<VoiceRecorderSheet> createState() => _SheetSelectState();
}

class _SheetSelectState extends State<VoiceRecorderSheet> {
  bool userClose = true;
  bool started = false;

  int recordTime = 0;

  IconData recordIcon = Icons.keyboard_voice_sharp;

  final AudioRecorder _record = AudioRecorder();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  File? lastFile;
  Uint8List? lastUint8List;

  @override
  void initState() {
    super.initState();

    _stopWatchTimer.rawTime.listen((final int value) {
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
  Widget build(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            StopWatchTimer.getDisplayTime(recordTime),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _addButton(
                  Icons.close,
                  () {
                    Navigator.pop(context);
                  },
                  30,
                  false,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: _addButton(
                    recordIcon,
                    () {
                      if (started) {
                        _pausePlay();
                      } else {
                        _startRecord();
                      }
                    },
                    40,
                    true,
                  ),
                ),
                _addButton(
                  Icons.stop,
                  () async {
                    /// get voice record data
                    await _stopRecord();

                    if (lastUint8List != null) {
                      userClose = false;
                      widget.onSelected.call(
                        FullPickerOutput(
                          <Uint8List?>[lastUint8List],
                          FullPickerType.voiceRecorder,
                          <String?>[widget.voiceFileName],
                          <File?>[lastFile],
                        ),
                      );
                    } else {
                      _showNotStartToast();
                    }
                  },
                  30,
                  false,
                ),
              ],
            ),
          ),
        ],
      );

  /// add voice record buttons
  ElevatedButton _addButton(
    final IconData icon,
    final VoidCallback onPressed,
    final double size,
    final bool hasBackgroundColor,
  ) =>
      ElevatedButton(
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
              : Theme.of(widget.context).colorScheme.onSurface.withAlpha(10),
        ),
        child: Icon(
          icon,
          color: Theme.of(widget.context).colorScheme.onSurface,
          size: size,
        ),
      );

  /// initialize and start record
  Future<void> _startRecord() async {
    started = true;
    if (await _record.hasPermission()) {
      _stopWatchTimer
        ..onResetTimer()
        ..onStartTimer();
      setState(() {
        recordIcon = Icons.pause;
      });

      await _record.start(
        const RecordConfig(),
        path: '${(await path_provider.getTemporaryDirectory()).path}/audio.mp3',
      );
    }
  }

  /// stop and return record data
  Future<void> _stopRecord() async {
    if (!started) {
      return;
    }
    try {
      final String? value = await _record.stop();
      if (isWeb) {
        final Response result = await get(Uri.parse(value!));

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

      await _record.resume();
    } else {
      _stopWatchTimer.onStopTimer();

      setState(() {
        recordIcon = Icons.keyboard_voice_sharp;
      });

      await _record.pause();
    }
  }

  /// show Not Start Voice Record Toast
  void _showNotStartToast() {
    showFullPickerToast(globalFullPickerLanguage.noVoiceRecorded, context);
  }
}
