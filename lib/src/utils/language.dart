/// language texts
class Language {
  String camera = "Camera";
  String selectFile = "Please select a file";
  String file = "File";
  String voiceRecorder = "Voice Recorder";
  String url = "URL";
  String enterURL = "Enter the URL";
  String cancel = "Cancel";
  String ok = "OK";
  String gallery = "Gallery";
  String cropper = "Photo cropping";
  String onCompressing = "Compressing...";
  String tapForPhotoHoldForVideo = "Tap for photo, hold for video";
  String cameraNotFound = "Camera not found !";
  String noVoiceRecorded = "No voice recorded";
  String denyAccessPermission =
      "Unfortunately, you denied access, so it is not possible to use this part";

  Language();

  /// help for cheng language texts
  Language.copy(
      {required this.camera,
      required this.file,
      required this.voiceRecorder,
      required this.gallery,
      required this.cropper,
      required this.url,
      required this.enterURL,
      required this.ok,
      required this.cancel,
      required this.cameraNotFound,
      required this.denyAccessPermission,
      required this.onCompressing,
      required this.noVoiceRecorded,
      required this.selectFile,
      required this.tapForPhotoHoldForVideo});
}
