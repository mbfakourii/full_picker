import 'dart:async';
import 'dart:io' as io;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file/file.dart';
import 'package:path_provider/path_provider.dart';

import '../../full_picker.dart';

class SheetAudioRecorder extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final BuildContext? context;
  final ValueSetter<OutputFile>? onSelected;
  final ValueSetter<int>? onError;
  bool image;
  bool audio;
  bool video;
  bool file;

  SheetAudioRecorder(this.image, this.audio, this.video, this.file,
      {localFileSystem, this.context, this.onSelected, this.onError})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  State<StatefulWidget> createState() => new SheetAudioRecorderState();
}

class SheetAudioRecorderState extends State<SheetAudioRecorder> {
  FlutterAudioRecorder2? _recorder;
  late Recording _current;
  String textRecorder = language.ready;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  AudioPlayer audioPlayer = AudioPlayer();
  late Timer? timerStart;
  bool userClose = true;
  late IconData iconFirstRecorder;
  late IconData iconTwoStopRecorderPlay;
  late IconData iconThreeSendCancel;
  late Color colorThreeSendCancel;
  Color stopColorBack = Colors.grey;
  late File? lastFileSelect;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    if (timerStart != null) {
      timerStart!.cancel();
    }

    audioPlayer.dispose();

    if (userClose) {
      if (_currentStatus != RecordingStatus.Initialized) {
        // _recorder.stop();
      }
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
                  topSheet(
                    widget.image,
                    widget.audio,
                    widget.video,
                    widget.file,
                    language.record_audio,
                    false,
                    widget.context!,
                    true,
                    widget.onSelected!,
                    widget.onError!,
                    false,
                    onBack: (value) {
                      userClose = false;
                    },
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Color(0xfff2f6ff),
                      ),
                      child: Icon(
                        Icons.keyboard_voice,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "$textRecorder : ${_current.duration.toString().split('.')[0]}",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      recorderButton(() async {
                        if (_currentStatus == RecordingStatus.Paused) {
                          _resume();
                        } else if (_currentStatus ==
                            RecordingStatus.Recording) {
                          _pause();
                        } else {
                          if (audioPlayer.state == PlayerState.PLAYING) {
                            audioPlayer.stop();
                            await audioPlayer.release();
                            timerStart!.cancel();
                          }
                          if (_currentStatus == RecordingStatus.Stopped) {
                            await _init();
                            _start();
                          } else {
                            _start();
                          }
                        }
                      }, iconFirstRecorder, Color(0xFFE2E2E2), Colors.white),
                      SizedBox(width: 20),
                      recorderButton(() {
                        if (_currentStatus == RecordingStatus.Initialized) {
                          Fluttertoast.showToast(
                              msg: language.for_recording_button_record_audio,
                              toastLength: Toast.LENGTH_SHORT);
                        } else if (_currentStatus == RecordingStatus.Stopped) {
                          onPlayAudio();
                        } else if (_currentStatus != RecordingStatus.Unset) {
                          _stop();
                        } else {
                          // _currentStatus = null;
                        }
                      }, iconTwoStopRecorderPlay, Color(0xFFE2E2E2), stopColorBack),
                      SizedBox(width: 20),
                      recorderButton(() {
                        if (lastFileSelect == null) {
                          userClose = false;
                          Navigator.of(context).pop();
                          widget.onError!.call(1);
                        } else {
                          userClose = false;
                          Navigator.of(context).pop();
                          widget.onSelected!.call(OutputFile(
                              lastFileSelect!, PickerFileType.AUDIO));
                        }
                      }, iconThreeSendCancel, colorThreeSendCancel,
                          Colors.white),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ])));
  }

  Widget recorderButton(
      Function onTap, IconData icon, Color color, Color colorBack) {
    return ClipOvalShadow(
        shadow: Shadow(
          color: Color(0xFFE6E6E6),
          blurRadius: 4,
        ),
        clipper: CustomClipperOval(),
        child: ClipOval(
            child: Material(
                color: colorBack,
                child: InkWell(
                    child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          icon,
                          color: color,
                          size: 25,
                        )),
                    onTap: () => onTap))));
  }

  _init() async {
    setStyleIcons();
    try {
      if (await FlutterAudioRecorder2.hasPermissions ?? false) {
        io.Directory appDocDirectory;

        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = (await getExternalStorageDirectory())!;
        }

        String customPath = '${appDocDirectory.path}/Audio/';
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        _recorder =
            FlutterAudioRecorder2(customPath, audioFormat: AudioFormat.AAC);

        await _recorder!.initialized;

        var current = await _recorder!.current(channel: 0);

        setState(() {
          _current = current!;
          _currentStatus = current.status!;
        });
      } else {
        userClose = false;

        Fluttertoast.showToast(
            msg: language.deny_access_permission,
            toastLength: Toast.LENGTH_SHORT);

        backArrowButton(
            widget.context!,
            false,
            true,
            widget.image,
            widget.audio,
            widget.video,
            widget.file,
            widget.onSelected!,
            widget.onError!,
            false);
      }
    } catch (_) {}
  }

  _start() async {
    try {
      await _recorder!.start();
      var recording = await _recorder!.current(channel: 0);
      setState(() {
        _current = recording!;
        textRecorder = language.recording;
        _currentStatus = _current.status!;
        setStyleIcons();
      });

      const tick = const Duration(seconds: 1);
      timerStart = new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder!.current(channel: 0);

        setState(() {
          _current = current!;
          _currentStatus = _current.status!;
        });
      });
    } catch (e) {}
  }

  _resume() async {
    await _recorder!.resume();
    await updateCurrentStatus();
    setState(() {
      setStyleIcons();
    });
  }

  _pause() async {
    await _recorder!.pause();
    await updateCurrentStatus();
    setState(() {
      textRecorder = language.pause;
      setStyleIcons();
    });
  }

  Future<void> updateCurrentStatus() async {
    var recording = await _recorder!.current(channel: 0);
    _current = recording!;
    _currentStatus = _current.status!;
  }

  _stop() async {
    var result = await _recorder!.stop();
    lastFileSelect = widget.localFileSystem.file(result!.path);

    setState(() {
      _current = result;
      _currentStatus = _current.status!;
      setStyleIcons();
    });
  }

  bool initAudio = false;
  String lastPath = "";

  void onPlayAudio() async {
    if (_current.path != null) {
      lastPath = _current.path!;
    }

    if (initAudio == false) {
      await audioPlayer.play(lastPath, isLocal: true);
      audioPlayer.onAudioPositionChanged.listen((event) {
        Recording recording = Recording();
        recording.duration = event;
        textRecorder = language.playing;
        _current = recording;
        try {
          setState(() {});
        } catch (_) {}
      });

      audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          setStyleIcons(type: 2);
        });
      });

      initAudio = true;
    } else {
      if (audioPlayer.state == PlayerState.PLAYING) {
        audioPlayer.pause();
        setState(() {
          setStyleIcons(type: 2);
        });
      } else {
        audioPlayer.play(lastPath);
        setState(() {
          setStyleIcons(type: 1);
        });
      }
    }
  }

  // type = {1 : play , 2 : pause}
  void setStyleIcons({int type = -1}) {
    if (type == 1) {
      iconFirstRecorder = Icons.record_voice_over_sharp;
      iconTwoStopRecorderPlay = Icons.pause;
      iconThreeSendCancel = Icons.send;
      colorThreeSendCancel = Color(0xfff2f6ff);
      stopColorBack = Colors.white;
    } else if (type == 2) {
      iconFirstRecorder = Icons.record_voice_over_sharp;
      iconTwoStopRecorderPlay = Icons.play_arrow;
      iconThreeSendCancel = Icons.send;
      colorThreeSendCancel = Color(0xfff2f6ff);
      stopColorBack = Colors.white;
    } else {
      switch (_currentStatus) {
        case RecordingStatus.Initialized:
          {
            iconFirstRecorder = Icons.record_voice_over_sharp;
            iconTwoStopRecorderPlay = Icons.play_arrow;
            iconThreeSendCancel = Icons.close;
            colorThreeSendCancel = Color(0xFFE2E2E2);
            stopColorBack = Colors.grey;
            break;
          }
        case RecordingStatus.Unset:
          {
            iconFirstRecorder = Icons.record_voice_over_sharp;
            iconTwoStopRecorderPlay = Icons.play_arrow;
            iconThreeSendCancel = Icons.close;
            colorThreeSendCancel = Color(0xFFE2E2E2);
            stopColorBack = Colors.grey;
            break;
          }
        case RecordingStatus.Recording:
          {
            iconFirstRecorder = Icons.pause;
            iconTwoStopRecorderPlay = Icons.stop;
            iconThreeSendCancel = Icons.close;
            colorThreeSendCancel = Color(0xFFE2E2E2);
            stopColorBack = Colors.white;
            break;
          }
        case RecordingStatus.Paused:
          {
            iconFirstRecorder = Icons.record_voice_over_sharp;
            iconTwoStopRecorderPlay = Icons.stop;
            iconThreeSendCancel = Icons.close;
            colorThreeSendCancel = Color(0xFFE2E2E2);
            stopColorBack = Colors.white;
            break;
          }
        case RecordingStatus.Stopped:
          {
            iconFirstRecorder = Icons.record_voice_over_sharp;
            iconTwoStopRecorderPlay = Icons.play_arrow;
            iconThreeSendCancel = Icons.send;
            colorThreeSendCancel = Color(0xfff2f6ff);
            stopColorBack = Colors.white;
            break;
          }
        default:
          break;
      }
    }
  }
}
