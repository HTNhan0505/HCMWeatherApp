import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'file_utils.dart';

Future<String> downloadAndResizeAndSaveImage(
    String url, String fileName) async {
  return await compute(
      _downloadResizeAndSave, {'url': url, 'fileName': fileName});
}

Future<String> _downloadResizeAndSave(Map<String, String> args) async {
  final url = args['url']!;
  final fileName = args['fileName']!;
  // 1. Download image
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw Exception('Failed to download image');
  final bytes = response.bodyBytes;
  // 2. Decode image
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  // 3. Resize image
  final int newWidth = (image.width / 2).round();
  final int newHeight = (image.height / 2).round();
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    ui.Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
    paint,
  );
  final resizedImage =
      await recorder.endRecording().toImage(newWidth, newHeight);
  final byteData =
      await resizedImage.toByteData(format: ui.ImageByteFormat.png);
  final resizedBytes = byteData!.buffer.asUint8List();
  // 4. Save to document directory
  return await saveBytesToDocumentDirectory(resizedBytes, fileName);
}

Future<Uint8List> downloadImageBytes(String url) async {
  return await compute(_downloadImageBytes, url);
}

Future<Uint8List> _downloadImageBytes(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw Exception('Failed to download image');
  return response.bodyBytes;
}
