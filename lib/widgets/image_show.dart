import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/common_utils.dart';

//ignore: must_be_immutable
class ImageShow extends StatelessWidget {
  ImageShow(this.url, {Key? key, this.fit, this.width, this.height}) : super(key: key) {
    isVideo = isUrlHasVideo(url);
  }

  final BoxFit? fit;

  final double? width;
  final double? height;

  String url;
  bool isFirst = true;
  bool isVideo = false;

  void checkUrl() async {
    if (isUrlHasVideo(url)) {
      url = await generateVideoThumbnail(url);
    }
    isFirst = false;
  }

  @override
  Widget build(BuildContext context) {
    return () {
      if (isVideo) {
        if (isFirst) {
          checkUrl();
          return const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        isFirst = true;
      }

      if (isLink(url)) {
        return CachedNetworkImage(
          fit: fit,
          imageUrl: url,
          width: width,
          height: height,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      } else if (url == "") {
        return Container();
      } else if (url.contains("assets")) {
        return Image.asset(
          url,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        );
      } else {
        return Image.file(
          File(url),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        );
      }
    }();
  }
}
