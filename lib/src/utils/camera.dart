import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:io' as io;

import '../../full_picker.dart';

class Camera extends StatefulWidget {
  final ValueSetter<OutputFile> onSelected;
  final ValueSetter<int> onError;
  final bool isTakeImage;

  const Camera(
      {Key? key,
      required this.onSelected,
      required this.onError,
      required this.isTakeImage})
      : super(key: key);

  @override
  _CameraState createState() {
    return _CameraState();
  }
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  Color colorCameraButton = Colors.white;
  List<CameraDescription> cameras = [];
  CameraController? controller;
  String? videoPath;

  bool toggleCameraVisibility = true;
  bool stopVideoClick = false;
  bool recordVideoClick = false;
  bool firstCamera = true;
  bool userClose = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        cameras = await availableCameras();
        setState(() {});
      } catch (_) {}
    } on CameraException {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (userClose) {
      widget.onError.call(1);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller!.description);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _cameraPreviewWidget(),
            twoButton(),
          ],
        ),
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      onNewCameraSelected(cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.back));
    }

    double scale;
    try{
      scale = 1 / (controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio);
    }catch(e){
      scale=1.0;
    }

    return Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: CameraPreview(controller!),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String? filePath) {
      if (filePath == "") return;
      if (mounted) {
        setState(() {
          Navigator.pop(context);
        });
        userClose = false;
        widget.onSelected
            .call(OutputFile(File(filePath!), PickerFileType.IMAGE));
      }
    });
  }

  Future<void> onVideoRecordButtonPressed() async {
    startVideoRecording().then((value) {
      if (mounted) setState(() {});
    });
  }

  Future<void> onStopButtonPressed() async {
    stopVideoRecording().then((file) {
      if (mounted)
        setState(() {
          Navigator.pop(context);
        });
      userClose = false;
      widget.onSelected
          .call(OutputFile(File(file!.path), PickerFileType.VIDEO));
    });
  }

  Future<void> startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      return;
    }

    Directory extDir;

    if (io.Platform.isIOS) {
      extDir = await getApplicationDocumentsDirectory();
    } else {
      extDir = (await getExternalStorageDirectory())!;
    }
    final String dirPath = '${extDir.path}/Video';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller!.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      videoPath = filePath;
      await controller!.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    await Future.delayed(Duration(seconds: 1));

    try {
      return controller!.stopVideoRecording();
    } catch (e) {
      Navigator.pop(context);
    }
  }

  Future<String?> takePicture() async {
    if (!controller!.value.isInitialized) {
      return "";
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures';
    await Directory(dirPath).create(recursive: true);

    if (controller!.value.isTakingPicture) {
      return "";
    }

    try {
      XFile file = await controller!.takePicture();
      return file.path;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    if (e.code == "cameraPermission") {
      Navigator.pop(context);
      widget.onError.call(1);

      Fluttertoast.showToast(
          msg: language.deny_access_permission,
          toastLength: Toast.LENGTH_SHORT);
    }
  }

  twoButton() {
    return Container(
      // remove this height
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Visibility(
            visible: toggleCameraVisibility,
            child: Expanded(
              child: SizedBox(
                width: double.infinity,
                child: IconButton(
                    icon: Icon(
                      Icons.flip_camera_android,
                      color: Colors.red,
                      size:  0.15.w,
                    ),
                    onPressed: () {
                      changeCamera();
                    }),
              ),
            ),
          ),
          const Expanded(
            flex: 5,
            child: SizedBox(
              height: 15,
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: IconButton(
                  icon: Icon(
                    Icons.camera,
                    color: colorCameraButton,
                    size: 0.15.w,
                  ),
                  onPressed: () {
                    if (widget.isTakeImage) {
                      onTakePictureButtonPressed();
                    } else {
                      if (stopVideoClick) return;
                      setState(() {
                        toggleCameraVisibility = false;
                        colorCameraButton = Colors.green;
                      });
                      if (controller!.value.isRecordingVideo) {
                        stopVideoClick = true;
                        onStopButtonPressed();
                      } else {
                        if (recordVideoClick) return;
                        recordVideoClick = true;
                        onVideoRecordButtonPressed();
                      }
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }

  void changeCamera() {
    if (firstCamera) {
      firstCamera = false;
      onNewCameraSelected(cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.front));

    } else {
      onNewCameraSelected(cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.back));
      firstCamera = true;
    }

  }
}
