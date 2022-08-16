import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';

convertHashMapListToPointer(dynamic parseHashMap) {
  return encodeObject(parseHashMap['className'], parseHashMap['objectId']);
}

toTimeIran(DateTime dateTime) {
  // return dateTimeToZone(zone: 'IRST', datetime: dateTime);
  initializeTimeZones();

  final pacificTimeZone = UTC;

  return TZDateTime.from(dateTime, pacificTimeZone);
}

String replaceFarsiNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], farsi[i]);
  }

  return input;
}

Future<void> saveIsReject() async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;

  prefs.setBool("reject", true);
}

Future<bool> isReject() async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  return prefs.getBool("reject") ?? false;
}

dynamic convertParseUserToUser(ParseUser parseUser) {
  // ignore: INVALID_USE_OF_PROTECTED_MEMBER
  // return User.fromJson(parseUser.toJson());
}

//print with debug Print
p(e) {
  debugPrint(e.toString());
}

// go Another Page
Future<dynamic> go(context, Widget widget, {bool close = false}) {
  if (close) {
    return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
  } else {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }
}

void showError(e) {
  debugPrint("show error --- > $e");
}

bool isNull(dynamic value) {
  if (value != null) {
    return false;
  } else {
    return true;
  }
}

void toastShow(value) {
  showToast(
    value,
    position: ToastPosition.bottom,
  );
}

void closeKeyboard(context, bool clear) {
  if (clear) {
    FocusScope.of(context).unfocus();
  } else {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        FocusScope.of(context).nextFocus();
      }
    }
  }
}

void showVideoPlayer(parentContext, String address) async {
  // await Navigator.of(parentContext).push(MaterialPageRoute(builder: (context) => VideoPlayer(address)));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

void showImageView(parentContext, String address) async {
  // Navigator.of(parentContext).push(MaterialPageRoute(builder: (context) => ExpandedImageView(address)));
}

bool isNumeric(String string) {
  if (string.isEmpty) {
    return false;
  }

  final number = num.tryParse(string);

  if (number == null) {
    return false;
  }

  return true;
}

Future<File> changeFileNameOnly(File file, String newFileName) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}

String getFileNameInModelNameFile(String pathh) {
  String basename = path.basename(pathh);
  List<String> splits = basename.split("_");
  return splits[1];
}

String getFileNameFromUrl(String url) {
  return url.split('/').last;
}

ParseFile? getVideoThumbnailListParseFile(List<dynamic> thumbnailFiles, String presentationFileUrl) {
  for (int i = 0; i < thumbnailFiles.length; i++) {
    if (getFileNameInModelNameFile(thumbnailFiles[i]['url']!) == getFileNameInModelNameFile(presentationFileUrl)) {
      return thumbnailFiles[i];
    }
  }
  return null;
}

Future<String> generateVideoThumbnail(String path) async {
  Uint8List byteData;
  try {
    final thumbnailFile = await VideoCompress.getFileThumbnail(path,
        quality: 50, // default(100)
        position: -1 // default(-1)
        );

    return thumbnailFile.path;
  } catch (e) {
    final b = await rootBundle.load('assets/images/logo.png');
    byteData = b.buffer.asUint8List();
  }

  Directory extDir;
  if (io.Platform.isIOS) {
    extDir = await getApplicationDocumentsDirectory();
  } else {
    extDir = (await getExternalStorageDirectory())!;
  }
  String dirPAth = "${extDir.path}/Pictures";
  await Directory(dirPAth).create(recursive: true);
  File file = File('$dirPAth/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');
  await file.writeAsBytes(byteData);

  return file.path;
}

bool isUrlHasVideo(String path) {
  RegExp exp = RegExp(
      r"((?:www\.)?(?:\S+)(?:%2F|\/)(?:(?!\.(?:mp4|mkv|wmv|m4v|mov|avi|flv|webm|flac|mka|m4a|aac|ogg))[^\/])*\.(mp4|mkv|wmv|m4v|mov|avi|flv|webm|flac|mka|m4a|aac|ogg))(?!\/|\.[a-z]{1,3})");

  if (exp.hasMatch(path)) {
    return true;
  } else {
    return false;
  }
}

bool isLink(link) {
  try {
    return link.contains("http");
  } catch (e) {
    return false;
  }
}

exitApplication() {
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

openLink(link, context) async {
  if (isLink(link)) {
    await launchUrl(link);
  } else {
    try {
      List<String> splits = link.split(":");
      splits[1];
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => Detail(splits[1], splits[0] == "Post" ? true : false)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }
}

String toPersian(String time) {
  time = replaceFarsiNumber(time);
  time = time.replaceAll("a few seconds", "چند ثانیه");
  time = time.replaceAll("a minute", "یک دقیقه");
  time = time.replaceAll("minutes", "دقیقه");
  time = time.replaceAll("an hour", "یک ساعت");
  time = time.replaceAll("hours", "ساعت");
  time = time.replaceAll("a day", "یک روز");
  time = time.replaceAll("days", "روز");
  time = time.replaceAll("a month", "یک ماه");
  time = time.replaceAll("months", "ماه");
  time = time.replaceAll("a year", "یک سال");
  time = time.replaceAll("years", "سال");
  time = time.replaceAll("in", "در");
  time = time.replaceAll("ago", "پیش");
  return time;
}

/// A method returns a human readable string representing a file _size
String fileSize(dynamic size, [int round = 2]) {
  /**
   * [size] can be passed as number or as string
   *
   * the optional parameter [round] specifies the number
   * of digits after comma/point (default is 2)
   */
  int divider = 1024;
  int _size;
  try {
    _size = int.parse(size.toString());
  } catch (e) {
    throw ArgumentError("Can not parse the size parameter: $e");
  }

  if (_size < divider) {
    return "$_size B";
  }

  if (_size < divider * divider && _size % divider == 0) {
    return "${(_size / divider).toStringAsFixed(0)} KB";
  }

  if (_size < divider * divider) {
    return "${(_size / divider).toStringAsFixed(round)} KB";
  }

  if (_size < divider * divider * divider && _size % divider == 0) {
    return "${(_size / (divider * divider)).toStringAsFixed(0)} MB";
  }

  if (_size < divider * divider * divider) {
    return "${(_size / divider / divider).toStringAsFixed(round)} MB";
  }

  if (_size < divider * divider * divider * divider && _size % divider == 0) {
    return "${(_size / (divider * divider * divider)).toStringAsFixed(0)} GB";
  }

  if (_size < divider * divider * divider * divider) {
    return "${(_size / divider / divider / divider).toStringAsFixed(round)} GB";
  }

  if (_size < divider * divider * divider * divider * divider && _size % divider == 0) {
    num r = _size / divider / divider / divider / divider;
    return "${r.toStringAsFixed(0)} TB";
  }

  if (_size < divider * divider * divider * divider * divider) {
    num r = _size / divider / divider / divider / divider;
    return "${r.toStringAsFixed(round)} TB";
  }

  if (_size < divider * divider * divider * divider * divider * divider && _size % divider == 0) {
    num r = _size / divider / divider / divider / divider / divider;
    return "${r.toStringAsFixed(0)} PB";
  } else {
    num r = _size / divider / divider / divider / divider / divider;
    return "${r.toStringAsFixed(round)} PB";
  }
}

String ellipsisTextString(String text, int length) {
  if (text.length > length) {
    text = text.substring(0, length) + "...";
  }
  return text;
}

ParseObject convertHashMapToParseObject(dynamic hashMap) {
  try {
    ParseObject parseObject = ParseObject(hashMap['className']);

    hashMap.forEach((key, value) {
      parseObject.set(key, value);
    });

    return parseObject;
  } catch (e) {
    return hashMap;
  }
}

ParseRelation convertHashMapToParseRelation(dynamic hashMap, ParseObject aa) {
  try {
    ParseObject parseObject2 = ParseObject(hashMap['className']);
    ParseRelation parseObject = ParseRelation(key: hashMap["className"], parent: parseObject2);
    return parseObject;
  } catch (e) {
    return hashMap;
  }
}

String dateToJalali(dynamic dateTime2, {bool showTime = false, bool showOnlyTime = false}) {
  DateTime? dateTime;
  try {
    dateTime = DateTime.tryParse(dateTime2);
  } catch (e) {
    dateTime = dateTime2;
  }

  if (dateTime == null) {
    return "ندارد";
  } else {
    if (showOnlyTime) {
      final detroit = getLocation('Asia/Tehran');
      final localizedDt = TZDateTime.from(dateTime, detroit);
      return "${localizedDt.hour}:${localizedDt.minute}";
    }

    if (showTime) {
      final detroit1 = getLocation('Asia/Tehran');
      final localizedDt1 = TZDateTime.from(dateTime, detroit1);

      return localizedDt1.hour.toString() +
          ":" +
          localizedDt1.minute.toString() +
          " - " +
          Jalali.fromDateTime(toTimeIran(dateTime)).formatCompactDate();
    } else {
      return Jalali.fromDateTime(toTimeIran(dateTime)).formatCompactDate();
    }
  }
}

fromDateTimeToJalali(DateTime dateTime) {
  Jalali? picked3 = Jalali.fromDateTime(dateTime);
  return Jalali(picked3.year, picked3.month, picked3.day, dateTime.hour, dateTime.minute, dateTime.second);
}
