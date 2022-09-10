import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../full_picker.dart';

// Custom Camera for Image and Video
class Camera extends StatefulWidget {
  final bool videoCamera;
  final bool imageCamera;
  final String prefixName;

  const Camera(
      {Key? key,
      required this.imageCamera,
      required this.videoCamera,
      required this.prefixName})
      : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  Color colorCameraButton = Colors.white;
  List<CameraDescription> cameras = [];
  CameraController? controller;

  bool toggleCameraAndTextVisibility = true;
  bool stopVideoClick = false;
  bool recordVideoClick = false;
  bool firstCamera = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  // init Camera
  Future<void> _init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        cameras = await availableCameras();
        setState(() {});
      } catch (e) {
        showToast(globalLanguage.cameraNotFound, context);

        Navigator.of(context).pop();
      }
    } on CameraException {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _cameraPreviewWidget(),
            buttons(),
          ],
        ),
      ),
    );
  }

  // Main Widget for Camera
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      onNewCameraSelected(cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back));
    }

    // Set aspectRatio Camera
    double scale;
    try {
      scale = 1 /
          (controller!.value.aspectRatio *
              MediaQuery.of(context).size.aspectRatio);
    } catch (e) {
      scale = 1.0;
    }

    return Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: CameraPreview(controller!),
    );
  }

  // initialize Camera Controller
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

  // Take Picture
  void onTakePictureButtonPressed() {
    takePicture().then((String? filePath) {
      if (filePath == "") return;
      if (mounted) {
        Navigator.pop(
            context,
            OutputFile([File(filePath!).readAsBytesSync()],
                FilePickerType.image, ["${widget.prefixName}.jpg"]));
      }
    });
  }

  // Stop Video Recording
  Future<void> onStopButtonPressed() async {
    stopVideoClick = true;
    stopVideoRecording().then((file) {
      if (mounted) {
        Navigator.pop(
            context,
            OutputFile([File(file!.path).readAsBytesSync()],
                FilePickerType.video, ["${widget.prefixName}.mp4"]));
      }
    });
  }

  // Start Video Recording
  Future<void> startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      return;
    }

    if (controller!.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await controller!.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  // Stop Video Recording
  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    await Future.delayed(const Duration(seconds: 1));

    try {
      return controller!.stopVideoRecording();
    } catch (_) {}
    return null;
  }

  // Take Picture
  Future<String?> takePicture() async {
    if (!controller!.value.isInitialized) {
      return "";
    }

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

  // show Camera Exception
  void _showCameraException(CameraException e) {
    if (e.code == "cameraPermission" || e.code == "CameraAccessDenied") {
      if (mounted) {
        Navigator.pop(context);
      }

      showToast(globalLanguage.denyAccessPermission, context);
    }
  }

  // struct buttons in main page
  buttons() {
    return Container(
      // remove this height
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      child: Column(
        children: [
          Visibility(
            visible: toggleCameraAndTextVisibility,
            child: Expanded(
              child: SizedBox(
                width: double.infinity,
                child: IconButton(
                    icon: const Icon(
                      Icons.flip_camera_android,
                      color: Colors.red,
                      size: 60,
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
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: (widget.imageCamera && widget.videoCamera) &&
                toggleCameraAndTextVisibility,
            child: Text(globalLanguage.tapForPhotoHoldForVideo,
                style: const TextStyle(color: Color(0xa3ffffff), fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 15),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onLongPress: widget.videoCamera && widget.imageCamera
                    ? () {
                        videoRecord();
                      }
                    : null,
                onTap: () {
                  if (widget.imageCamera) {
                    if (controller!.value.isRecordingVideo) {
                      onStopButtonPressed();
                    } else {
                      onTakePictureButtonPressed();
                    }
                  } else {
                    videoRecord();
                  }
                },
                child: Icon(
                  Icons.camera,
                  color: colorCameraButton,
                  size: 60,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // change Camera
  void changeCamera() {
    if (firstCamera) {
      firstCamera = false;
      onNewCameraSelected(cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front));
    } else {
      onNewCameraSelected(cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back));
      firstCamera = true;
    }
  }

  // Video Recording
  void videoRecord() {
    if (stopVideoClick) return;
    setState(() {
      toggleCameraAndTextVisibility = false;
      colorCameraButton = Colors.green;
    });
    if (controller!.value.isRecordingVideo) {
      onStopButtonPressed();
    } else {
      if (recordVideoClick) return;
      recordVideoClick = true;

      startVideoRecording().then((value) {
        if (mounted) setState(() {});
      });
    }
  }
}

bool get isWeb => kIsWeb;
