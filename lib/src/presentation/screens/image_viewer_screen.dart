import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/isolate_utils.dart';
import '../../core/utils/file_utils.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  bool _downloading = false;

  Future<void> _downloadImage() async {
    if (_downloading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Processing image please try again later')),
      );
      return;
    }
    setState(() => _downloading = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing handle image')),
    );
    try {
      final fileName =
          'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.png';
      // Load image in isolate
      final Uint8List bytes = await downloadImageBytes(widget.imageUrl);
      // Decode and resize on isolate
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
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
      // Save
      final path = await saveImageToGallery(resizedBytes, fileName);
      if (!mounted) return;
      setState(() => _downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved image successfully')),
      );
    } catch (e) {
      setState(() => _downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'An error occurred while saving the image, please try again:')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 48),
              ),
            ),
            if (_downloading) const SizedBox.shrink(),
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.white, size: 30),
                    onPressed: _downloading ? null : _downloadImage,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon:
                        const Icon(Icons.cancel, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
