// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_orientation/device_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:full_picker/full_picker.dart';
import 'package:full_picker/src/utils/pl.dart';
import 'package:image/image.dart' as img;

/// Custom Camera for Image and Video
class Camera extends StatefulWidget {
  const Camera({
    required this.imageCropper,
    required this.imageCamera,
    required this.videoCamera,
    required this.prefixName,
    super.key,
  });

  final bool imageCropper;
  final bool videoCamera;
  final bool imageCamera;
  final String prefixName;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  Color colorCameraButton = Colors.white;
  List<CameraDescription> cameras = <CameraDescription>[];
  CameraController? controller;

  bool toggleCameraAndTextVisibility = true;
  bool stopVideoClick = false;
  bool recordVideoClick = false;
  bool firstCamera = true;

  IconData flashLightIcon = Icons.flash_auto;

  StreamSubscription<dynamic>? _subscription;
  DeviceOrientation currentOrientation = DeviceOrientation.portraitUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _init();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Future<File> rotateWrongOrientedImage(
    final String imagePath,
    final DeviceOrientation orientation,
  ) async {
    final File originalFile = File(imagePath);
    final Uint8List imageBytes = await originalFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);

    img.Image fixedImage;

    if (orientation == DeviceOrientation.portraitUp) {
      fixedImage = img.copyRotate(originalImage!, angle: 0);
    } else if (orientation == DeviceOrientation.landscapeLeft) {
      fixedImage = img.copyRotate(originalImage!, angle: 90);
    } else if (orientation == DeviceOrientation.portraitDown) {
      fixedImage = img.copyRotate(originalImage!, angle: 180);
    } else if (orientation == DeviceOrientation.landscapeRight) {
      fixedImage = img.copyRotate(originalImage!, angle: -90);
    } else {
      fixedImage = img.copyRotate(originalImage!, angle: 0);
    }

    final File fixedFile =
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    return fixedFile;
  }

  /// init Camera
  Future<void> _init() async {
    _subscription =
        deviceOrientation$.listen((final DeviceOrientation orientation) {
      currentOrientation = orientation;
    });

    try {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        cameras = await availableCameras();
        setState(() {});
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        showFullPickerToast(globalFullPickerLanguage.cameraNotFound, context);

        Navigator.of(context).pop();
      }
    } on CameraException {
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller?.dispose();
    _subscription?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
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
  Widget build(final BuildContext context) {
    if (cameras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _cameraPreviewWidget(),
            _close(),
            _buttons(context),
          ],
        ),
      ),
    );
  }

  double _maxZoom = 1;
  double _minZoom = 1;
  double _zoom = 1;
  double _scaleFactor = 1;

  bool hasBackFrontCamera = false;

  /// Main Widget for Camera
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      // Check has Back or Front Camera
      for (final CameraDescription element in cameras) {
        if (element.lensDirection == CameraLensDirection.front) {
          hasBackFrontCamera = true;
        }
      }

      try {
        onNewCameraSelected(
          Pl.isWeb
              ? cameras.lastWhere(
                  (final CameraDescription description) =>
                      description.lensDirection == CameraLensDirection.back,
                )
              : cameras.firstWhere(
                  (final CameraDescription description) =>
                      description.lensDirection == CameraLensDirection.back,
                ),
        );
      } catch (_) {
        onNewCameraSelected(
          cameras.lastWhere(
            (final CameraDescription description) =>
                description.lensDirection == CameraLensDirection.external,
          ),
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (final ScaleStartDetails details) {
        _zoom = _scaleFactor;
      },
      onScaleUpdate: (final ScaleUpdateDetails details) {
        final double temp = _zoom * details.scale;
        if (temp <= _maxZoom && temp >= _minZoom) {
          _scaleFactor = temp;
        }
        controller!.setZoomLevel(_scaleFactor);
      },
      child: () {
        try {
          return controller!.buildPreview();
        } catch (_) {
          return const Center(child: CircularProgressIndicator());
        }
      }(),
    );
  }

  /// initialize Camera Controller
  Future<void> onNewCameraSelected(
    final CameraDescription cameraDescription,
  ) async {
    if (controller != null) {
      await controller!.dispose();
    }

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

    await _setMaxMinVideoSize();

    unawaited(_setFlashLightIcon(context));
  }

  /// Take Picture
  void onTakePictureButtonPressed() {
    final DeviceOrientation orientation = currentOrientation;

    takePicture().then((final String? filePath) async {
      if (filePath == '') {
        return;
      }
      XFile file;

      if (firstCamera) {
        file = XFile(
          (await rotateWrongOrientedImage(filePath!, orientation)).path,
        );
      } else {
        file = XFile(filePath!);
      }

      if (widget.imageCropper) {
        final XFile? cropFile = await cropImage(
          context: context,
          sourcePath: file.path,
        );

        if (cropFile == null) {
          return null;
        } else {
          file = cropFile;
        }
      }

      if (mounted) {
        final String extension = getFileExtensionFullPicker(file.path);
        final String fileName = generateFileName('image');

        Navigator.pop(
          context,
          FullPickerOutput(
            bytes: <Uint8List?>[await file.readAsBytes()],
            fileType: FullPickerType.image,
            name: <String?>[fileName + extension],
            file: <File?>[File(file.path)],
            xFile: <XFile?>[
              getFillXFile(
                file: File(file.path),
                bytes: await file.readAsBytes(),
                mime: 'image/jpeg',
                name: fileName + extension,
              ),
            ],
          ),
        );
      }
    });
  }

  /// Stop Video Recording
  Future<void> onStopButtonPressed() async {
    stopVideoClick = true;
    await stopVideoRecording().then((final XFile? file) async {
      if (file == null) {
        return;
      }

      if (mounted) {
        final String fileName = generateFileName('video');

        Navigator.pop(
          context,
          FullPickerOutput(
            bytes: <Uint8List?>[await file.readAsBytes()],
            fileType: FullPickerType.video,
            name: <String?>['${widget.prefixName}$fileName.mp4'],
            file: () {
              try {
                return <File?>[File(file.path)];
              } catch (_) {
                return <File?>[];
              }
            }(),
            xFile: <XFile?>[
              if (Pl.isWeb)
                file
              else
                getFillXFile(
                  file: () {
                    try {
                      return File(file.path);
                    } catch (_) {
                      return null;
                    }
                  }(),
                  bytes: await file.readAsBytes(),
                  mime: 'video/mp4',
                  name: '${widget.prefixName}$fileName.mp4',
                ),
            ],
          ),
        );
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

    await Future<void>.delayed(const Duration(seconds: 1));

    try {
      return controller!.stopVideoRecording();
    } catch (_) {}
    return null;
  }

  /// Take Picture
  Future<String?> takePicture() async {
    if (!controller!.value.isInitialized) {
      return '';
    }

    if (controller!.value.isTakingPicture) {
      return '';
    }

    try {
      final XFile file = await controller!.takePicture();
      return file.path;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  /// show Camera Exception
  void _showCameraException(final CameraException e) {
    if (e.code == 'cameraPermission' || e.code == 'CameraAccessDenied') {
      if (mounted) {
        Navigator.pop(context);
      }

      showFullPickerToast(
        globalFullPickerLanguage.denyAccessPermission,
        context,
      );
    }
  }

  /// struct buttons in main page
  Container _buttons(final BuildContext context) => Container(
        // remove this height
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.centerRight,
        child: Column(
          children: <Widget>[
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
              child: Text(
                globalFullPickerLanguage.tapForPhotoHoldForVideo,
                style: const TextStyle(color: Color(0xa3ffffff), fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: Row(
                children: <Widget>[
                  Visibility(
                    visible: hasBackFrontCamera,
                    replacement: Expanded(flex: 3, child: Container()),
                    child: Expanded(
                      flex: 3,
                      child: Visibility(
                        visible: toggleCameraAndTextVisibility,
                        child: IconButton(
                          icon: const Icon(
                            Icons.flip_camera_android,
                            color: Colors.white,
                            size: 33,
                          ),
                          onPressed: changeCamera,
                        ),
                      ),
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
                            ? videoRecord
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
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// change Camera
  void changeCamera() {
    if (firstCamera) {
      firstCamera = false;
      onNewCameraSelected(
        cameras.lastWhere(
          (final CameraDescription description) =>
              description.lensDirection == CameraLensDirection.front,
        ),
      );
    } else {
      onNewCameraSelected(
        Pl.isWeb
            ? cameras.lastWhere(
                (final CameraDescription description) =>
                    description.lensDirection == CameraLensDirection.back,
              )
            : cameras.firstWhere(
                (final CameraDescription description) =>
                    description.lensDirection == CameraLensDirection.back,
              ),
      );
      firstCamera = true;
    }
  }

  /// Video Recording
  void videoRecord() {
    if (stopVideoClick) {
      return;
    }
    setState(() {
      toggleCameraAndTextVisibility = false;
      colorCameraButton = Colors.red;
    });
    if (controller!.value.isRecordingVideo) {
      onStopButtonPressed();
    } else {
      if (recordVideoClick) {
        return;
      }
      recordVideoClick = true;

      startVideoRecording().then((final _) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> _setFlashLightIcon(final BuildContext context) async {
    if (controller!.value.flashMode == FlashMode.off) {
      flashLightIcon = Icons.flash_off;
    } else if (controller!.value.flashMode == FlashMode.auto) {
      flashLightIcon = Icons.flash_auto;
    } else {
      flashLightIcon = Icons.flash_on;
    }

    setState(() {});
  }

  Future<void> _toggleFlashLight(final BuildContext context) async {
    if (controller!.value.flashMode == FlashMode.off) {
      flashLightIcon = Icons.flash_auto;
      showFullPickerToast(globalFullPickerLanguage.auto, context);
      await controller!.setFlashMode(FlashMode.auto);
    } else if (controller!.value.flashMode == FlashMode.auto) {
      flashLightIcon = Icons.flash_on;
      showFullPickerToast(globalFullPickerLanguage.on, context);
      await controller!.setFlashMode(FlashMode.always);
    } else {
      flashLightIcon = Icons.flash_off;
      showFullPickerToast(globalFullPickerLanguage.off, context);
      await controller!.setFlashMode(FlashMode.off);
    }

    setState(() {});
  }

  Future<void> _setMaxMinVideoSize() async {
    _maxZoom = await controller!.getMaxZoomLevel();
    _minZoom = await controller!.getMinZoomLevel();
  }

  Widget _close() => PositionedDirectional(
        end: 0,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            end: 15,
            top: Pl.isWeb ? 10 : 26,
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 33,
            ),
          ),
        ),
      );
}
