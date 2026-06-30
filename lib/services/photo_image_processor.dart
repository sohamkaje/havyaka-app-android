import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PhotoImageProcessor {
  static const maxDimension = 2048;

  static Future<Uint8List?> prepareForUpload(Uint8List data) async {
    final result = await FlutterImageCompress.compressWithList(
      data,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: 85,
      autoCorrectionAngle: true,
    );
    return result;
  }
}
