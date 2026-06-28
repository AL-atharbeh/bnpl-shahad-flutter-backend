import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../config/env/env_dev.dart';

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

  /// Get the base server URL (strips /api/v1 from the baseUrl)
  static String get _serverUrl {
    final baseUrl = EnvDev.baseUrl;
    if (baseUrl.contains('/api/v1')) {
      return baseUrl.split('/api/v1')[0];
    }
    return baseUrl;
  }

  /// Build an image widget that supports network URLs, base64 data URLs, relative server paths, and asset paths
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

    // Process the URL: if it's a relative path from the server, prepend the server URL
    String processedUrl = imageUrl;
    if (!isNetworkUrl(imageUrl) && 
        !isBase64DataUrl(imageUrl) && 
        !imageUrl.startsWith('assets/')) {
      
      final server = _serverUrl;
      // Ensure there's a single slash between server and relative path
      final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
      processedUrl = '$server$path';
      
      debugPrint('🖼️ Prepending server URL to relative path: $processedUrl');
    }

    // Handle base64 data URLs
    if (isBase64DataUrl(processedUrl)) {
      final bytes = decodeBase64DataUrl(processedUrl);
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

    // Handle network URLs (including both full URLs and newly constructed server URLs)
    if (isNetworkUrl(processedUrl)) {
      return SmoothNetworkImage(
        url: processedUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: placeholder,
        errorWidget: defaultError,
        fallbackAsset: !imageUrl.startsWith('http') ? imageUrl : null,
      );
    }

    // Handle asset images correctly
    return Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => defaultError,
    );
  }
}

/// A network image widget that prevents flickering when its URL changes by keeping
/// the previous image visible until the new one is fully loaded in the background.
class SmoothNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final String? fallbackAsset;

  const SmoothNetworkImage({
    Key? key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
    this.fallbackAsset,
  }) : super(key: key);

  @override
  State<SmoothNetworkImage> createState() => _SmoothNetworkImageState();
}

class _SmoothNetworkImageState extends State<SmoothNetworkImage> {
  ImageProvider? _activeProvider;
  bool _isLoading = false;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(SmoothNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    if (widget.url.isEmpty) {
      setState(() {
        _activeProvider = null;
        _isLoading = false;
      });
      return;
    }

    final newProvider = NetworkImage(widget.url);
    _cleanup();

    setState(() {
      _isLoading = true;
    });

    final ImageStream newStream = newProvider.resolve(ImageConfiguration.empty);
    final ImageStreamListener listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!mounted) return;
        _activeProvider = newProvider;
        _isLoading = false;
        if (synchronousCall) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        } else {
          setState(() {});
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        if (!mounted) return;
        setState(() {
          _activeProvider = null;
          _isLoading = false;
        });
      },
    );

    _imageStream = newStream;
    _imageListener = listener;
    newStream.addListener(listener);
  }

  void _cleanup() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultError = widget.errorWidget ?? Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.store_rounded, color: Color(0xFF6B7280), size: 30),
    );

    if (_activeProvider == null) {
      if (_isLoading) {
        return widget.placeholder ?? Container(
          width: widget.width,
          height: widget.height,
          color: const Color(0xFFF1F5F9),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00A66A)),
          ),
        );
      } else {
        if (widget.fallbackAsset != null && widget.fallbackAsset!.isNotEmpty) {
          return Image.asset(
            widget.fallbackAsset!,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
            errorBuilder: (_, __, ___) => defaultError,
          );
        }
        return defaultError;
      }
    }

    return Image(
      image: _activeProvider!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        if (widget.fallbackAsset != null && widget.fallbackAsset!.isNotEmpty) {
          return Image.asset(
            widget.fallbackAsset!,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
            errorBuilder: (_, __, ___) => defaultError,
          );
        }
        return defaultError;
      },
    );
  }
}
