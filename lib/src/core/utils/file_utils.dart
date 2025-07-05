import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

Future<String> saveBytesToDocumentDirectory(
    List<int> bytes, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

Future<String> saveImageToGallery(Uint8List bytes, String fileName) async {
  const platform = MethodChannel('weather_hcm_app/gallery');
  final result = await platform.invokeMethod<String>(
    'saveImageToGallery',
    {'bytes': bytes, 'fileName': fileName},
  );
  return result ?? '';
}
