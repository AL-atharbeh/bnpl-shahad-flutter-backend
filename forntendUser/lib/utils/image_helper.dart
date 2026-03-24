import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Helper class to handle different image URL formats including base64 data URLs
class ImageHelper {
  /// Check if the URL is a base64 data URL
  static bool isBase64DataUrl(String url) {
    return url.startsWith('data:image');
  }

  /// Check if the URL is a network image (http/https)
  static bool isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Extract base64 data from a data URL
  static Uint8List? decodeBase64DataUrl(String dataUrl) {
    try {
      // Format: data:image/jpeg;base64,/9j/4AAQ...
      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex == -1) return null;
      final base64String = dataUrl.substring(commaIndex + 1);
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('❌ Error decoding base64 image: $e');
      return null;
    }
  }

  /// Build an image widget that supports network URLs, base64 data URLs, and asset paths
  static Widget buildImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    double? width,
    double? height,
  }) {
    final defaultError = errorWidget ?? Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.store_rounded, color: Color(0xFF6B7280), size: 30),
    );

    if (imageUrl.isEmpty) {
      return defaultError;
    }

    // Handle base64 data URLs
    if (isBase64DataUrl(imageUrl)) {
      final bytes = decodeBase64DataUrl(imageUrl);
      if (bytes != null) {
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => defaultError,
        );
      }
      return defaultError;
    }

    // Handle network URLs
    if (isNetworkUrl(imageUrl)) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? Container(
            width: width,
            height: height,
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00A66A)),
            ),
          );
        },
        errorBuilder: (_, __, ___) => defaultError,
      );
    }

    // Handle asset images
    return Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => defaultError,
    );
  }
}
