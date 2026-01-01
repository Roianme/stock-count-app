import 'package:flutter/material.dart';
import 'dart:typed_data';

class PreviewImageDialog extends StatelessWidget {
  final Uint8List imageBytes;

  const PreviewImageDialog({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height * 0.85,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
