import 'package:flutter/foundation.dart';

/// Stub engine used while ML Kit is switched off for simulator builds.
///
/// It returns no text, so the ID screens still run and every other flow can be
/// exercised on the simulator; only the automatic field extraction is inert and
/// the fields are filled in by hand.
class OcrEngine {
  static const bool isAvailable = false;

  Future<String> recognize(String imagePath) async {
    debugPrint(
      '⚠️ OCR is disabled in this build (ML Kit off for the simulator). '
      'Enter the ID details manually, or run tool/toggle_mlkit.sh on.',
    );
    return '';
  }

  void dispose() {}
}
