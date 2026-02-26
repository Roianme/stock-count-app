import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../utils/index.dart';

class PreviewImageDialog extends StatefulWidget {
  final Uint8List imageBytes;

  const PreviewImageDialog({super.key, required this.imageBytes});

  @override
  State<PreviewImageDialog> createState() => _PreviewImageDialogState();
}

class _PreviewImageDialogState extends State<PreviewImageDialog> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    // Reset zoom on double tap
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = context.isLandscape;
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width - 32;
    final maxHeight = screenSize.height - 100; // Account for close button

    // Maintain a 3:2 ratio in landscape and 2:3 in portrait.
    final aspectRatio = isLandscape ? 3 / 2 : 2 / 3;

    double previewWidth = maxWidth;
    double previewHeight = previewWidth / aspectRatio;

    if (previewHeight > maxHeight) {
      previewHeight = maxHeight;
      previewWidth = previewHeight * aspectRatio;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Zoomable image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _handleDoubleTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Reset Zoom'),
              ),
              const SizedBox(width: 16),
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
        ],
      ),
    );
  }
}
