/// language texts
class FullPickerLanguage {
  FullPickerLanguage();

  /// help for cheng language texts
  FullPickerLanguage.copy({
    required this.camera,
    required this.file,
    required this.voiceRecorder,
    required this.gallery,
    required this.cropper,
    required this.url,
    required this.enterURL,
    required this.ok,
    required this.on,
    required this.off,
    required this.auto,
    required this.cancel,
    required this.cameraNotFound,
    required this.denyAccessPermission,
    required this.onCompressing,
    required this.noVoiceRecorded,
    required this.selectFile,
    required this.tapForPhotoHoldForVideo,
  });

  String camera = 'Camera';
  String selectFile = 'Please select a file';
  String file = 'File';
  String voiceRecorder = 'Voice Recorder';
  String url = 'URL';
  String enterURL = 'Enter the URL';
  String cancel = 'Cancel';
  String ok = 'OK';
  String gallery = 'Gallery';
  String cropper = 'Photo cropping';
  String onCompressing = 'Compressing...';
  String tapForPhotoHoldForVideo = 'Tap for photo, hold for video';
  String cameraNotFound = 'Camera not found !';
  String noVoiceRecorded = 'No voice recorded';
  String off = 'Off';
  String on = 'On';
  String auto = 'Auto';
  String denyAccessPermission =
      'Unfortunately, you denied access, so it is not possible to use this part';
}
