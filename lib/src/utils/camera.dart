import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../full_picker.dart';

/// Custom Camera for Image and Video
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

  IconData flashLightIcon = Icons.flash_off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  /// init Camera
  Future<void> _init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        cameras = await availableCameras();
        setState(() {});
      } catch (e) {
        showFullPickerToast(globalLanguage.cameraNotFound, context);

        Navigator.of(context).pop();
      }
    } on CameraException {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller?.dispose();

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
            buttons(context),
          ],
        ),
      ),
    );
  }

  double _maxZoom = 1.0;
  double _minZoom = 1.0;
  double _zoom = 1.0;
  double _scaleFactor = 1.0;

  /// Main Widget for Camera
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      onNewCameraSelected(cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back));
    }

    /// Set aspectRatio Camera
    double scale;
    try {
      scale = 1 /
          (controller!.value.aspectRatio *
              MediaQuery.of(context).size.aspectRatio);
    } catch (e) {
      scale = 1.0;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (details) {
        _zoom = _scaleFactor;
      },
      onScaleUpdate: (details) {
        double temp = _zoom * details.scale;
        if (temp <= _maxZoom && temp >= _minZoom) {
          _scaleFactor = temp;
        }
        controller!.setZoomLevel(_scaleFactor);
      },
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: CameraPreview(controller!),
      ),
    );
  }

  /// initialize Camera Controller
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
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

    _setMaxMinVideoSize();
  }

  /// Take Picture
  void onTakePictureButtonPressed() {
    takePicture().then((String? filePath) {
      if (filePath == "") return;
      if (mounted) {
        Navigator.pop(
            context,
            FullPickerOutput(
                [File(filePath!).readAsBytesSync()],
                FullPickerType.image,
                ["${widget.prefixName}.jpg"],
                [File(filePath)]));
      }
    });
  }

  /// Stop Video Recording
  Future<void> onStopButtonPressed() async {
    stopVideoClick = true;
    stopVideoRecording().then((file) {
      if (mounted) {
        Navigator.pop(
            context,
            FullPickerOutput(
                [File(file!.path).readAsBytesSync()],
                FullPickerType.video,
                ["${widget.prefixName}.mp4"],
                [File(file.path)]));
      }
    });
  }

  /// Start Video Recording
  Future<void> startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      return;
    }

    if (controller!.value.isRecordingVideo) {
      /// A recording is already started, do nothing.
      return;
    }

    try {
      await controller!.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  /// Stop Video Recording
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

  /// Take Picture
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

  /// show Camera Exception
  void _showCameraException(CameraException e) {
    if (e.code == "cameraPermission" || e.code == "CameraAccessDenied") {
      if (mounted) {
        Navigator.pop(context);
      }

      showFullPickerToast(globalLanguage.denyAccessPermission, context);
    }
  }

  /// struct buttons in main page
  buttons(context) {
    return Container(
      // remove this height
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      child: Column(
        children: [
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
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Visibility(
                    visible: toggleCameraAndTextVisibility,
                    child: IconButton(
                        icon: const Icon(
                          Icons.flip_camera_android,
                          color: Colors.white,
                          size: 33,
                        ),
                        onPressed: () {
                          changeCamera();
                        }),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Material(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
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
                ),
                Expanded(
                  flex: 3,
                  child: Visibility(
                    visible: toggleCameraAndTextVisibility,
                    child: IconButton(
                        icon: Icon(
                          flashLightIcon,
                          color: Colors.white,
                          size: 33,
                        ),
                        onPressed: () {
                          _toggleFlashLight(context);
                        }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// change Camera
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

  /// Video Recording
  void videoRecord() {
    if (stopVideoClick) return;
    setState(() {
      toggleCameraAndTextVisibility = false;
      colorCameraButton = Colors.red;
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

  Future<void> _toggleFlashLight(context) async {
    if (controller!.value.flashMode == FlashMode.off) {
      flashLightIcon = Icons.flash_auto;
      showFullPickerToast(globalLanguage.auto, context);
      await controller!.setFlashMode(FlashMode.auto);
    } else if (controller!.value.flashMode == FlashMode.auto) {
      flashLightIcon = Icons.flash_on;
      showFullPickerToast(globalLanguage.on, context);
      await controller!.setFlashMode(FlashMode.always);
    } else {
      flashLightIcon = Icons.flash_off;
      showFullPickerToast(globalLanguage.off, context);
      await controller!.setFlashMode(FlashMode.off);
    }

    setState(() {});
  }

  Future<void> _setMaxMinVideoSize() async {
    _maxZoom = await controller!.getMaxZoomLevel();
    _minZoom = await controller!.getMinZoomLevel();
  }
}

bool get isWeb => kIsWeb;
