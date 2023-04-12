# Full picker
<a href="https://pub.dev/packages/full_picker"><img src="https://img.shields.io/pub/v/full_picker.svg" alt="Pub"></a></br>
A Flutter package that helps you select files in different modes

## Features
* Multi File picker
* Video Compressor
* Image Cropper
* Custom Camera
* Custom Name For Files
* Voice recorder
* URL picker
* Support Material 1,2,3


## Example App
<img src="https://raw.githubusercontent.com/mbfakourii/full_picker/master/example/screenshots/example.gif" width="300" height="550" />

## Usage
Quick simple usage example:

```dart
FullPicker(
  context: context,
  prefixName: "test",
  file: true,
  image: true,
  video: true,
  videoCamera: true,
  imageCamera: true,
  voiceRecorder: true,
  videoCompressor: false,
  imageCropper: false,
  multiFile: true,
  url: true,
  onError: (int value) {
    print(" ----  onError ----=$value");
  },
  onSelected: (value) {
    print(" ----  onSelected ----");
  },
);
```

and use ```minSdkVersion 21``` in your Module-level build.gradle file

## Video Compressor

If you need to compress the video (only support Android And IOS), add the following

### iOS

Add the following to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```
<key>NSPhotoLibraryUsageDescription</key>
<string>${PRODUCT_NAME} library Usage</string>
```

### Android

Add the following permissions in AndroidManifest.xml:

**API < 29**

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
android:maxSdkVersion="28"/>
```

**API >= 29**

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

Include this in your Project-level build.gradle file:
```groovy
allprojects {
    repositories {
        .
        .
        .
        maven { url 'https://jitpack.io' }
    }
}
```

Include this in your Module-level build.gradle file:

```groovy
implementation 'com.github.AbedElazizShe:LightCompressor:1.0.0
```

## Image Cropper
If you need to crop the image (only support Android And IOS), add the following

### Android

- Add UCropActivity into your AndroidManifest.xml

````xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
````

### iOS
- No configuration required

## Voice Recorder
If you need to voice recorder, add the following

### Android
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<!-- Optional, you'll have to check this permission by yourself. -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
min SDK: 19 (maybe higher => encoder dependent)

### iOS
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need to access to the microphone to record audio file</string>
```
min SDK: 11.0

### macOS
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need to access to the microphone to record audio file</string>
```

## Multi Language
There is a possibility of customization for different languages in this package</br>

```dart
Language language = Language.copy(
    camera: S.current.camera,
    selectFile: S.current.selectFile,
    file: S.current.file,
    voiceRecorder: S.current.voiceRecorder,
    url: S.current.url,
    enterURL: S.current.enterURL,
    cancel: S.current.cancel,
    ok: S.current.ok,
    gallery: S.current.gallery,
    cropper: S.current.cropper,
    onCompressing: S.current.onCompressing,
    tapForPhotoHoldForVideo: S.current.tapForPhotoHoldForVideo,
    cameraNotFound: S.current.cameraNotFound,
    noVoiceRecorded: S.current.noVoiceRecorded,
    denyAccessPermission: S.current.denyAccessPermission);
    
FullPicker(
  ...
  language: language,
  ...
);   
```

```S``` For intl Package

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).