import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class AssetImageView extends StatelessWidget {
  final String? imageUrl;
  final String? imageBase64;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget placeholder;
  final Widget error;

  const AssetImageView({
    super.key,
    required this.imageUrl,
    required this.imageBase64,
    required this.placeholder,
    required this.error,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedBase64 = (imageBase64 ?? '').trim();
    Uint8List? bytes;
    if (normalizedBase64.isNotEmpty) {
      try {
        bytes = base64Decode(normalizedBase64);
      } catch (_) {
        bytes = null;
      }
    }

    Widget result;
    if (bytes != null) {
      result = Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, imageError, stackTrace) =>
            SizedBox(width: width, height: height, child: error),
      );
    } else if ((imageUrl ?? '').trim().isNotEmpty) {
      result = Image.network(
        imageUrl!.trim(),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, imageError, stackTrace) =>
            SizedBox(width: width, height: height, child: error),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(width: width, height: height, child: placeholder);
        },
      );
    } else {
      result = SizedBox(width: width, height: height, child: error);
    }

    if (borderRadius == null) return result;
    return ClipRRect(
      borderRadius: borderRadius!,
      child: result,
    );
  }
}
