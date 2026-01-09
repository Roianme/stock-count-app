import 'package:flutter/material.dart';
import 'dart:typed_data';

class PreviewImageDialog extends StatelessWidget {
  final Uint8List imageBytes;

  const PreviewImageDialog({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    // Use fixed aspect ratio (1200:1800 = 2:3) for consistent preview sizing
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width - 32; // Account for inset padding
    final maxHeight = screenSize.height * 0.8;

    // Calculate constrained dimensions maintaining 2:3 aspect ratio
    double previewWidth = maxWidth;
    double previewHeight = previewWidth * 1.5; // 1800/1200 = 1.5

    if (previewHeight > maxHeight) {
      previewHeight = maxHeight;
      previewWidth = previewHeight / 1.5;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: previewWidth,
                height: previewHeight,
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
