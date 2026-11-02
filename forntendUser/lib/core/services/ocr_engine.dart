import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Real engine, backed by Google ML Kit.
///
/// ML Kit ships its iOS binaries without an arm64 simulator slice, so CocoaPods
/// drops arm64 from simulator builds and the app then has no valid destination
/// on an Apple Silicon Mac. Use tool/toggle_mlkit.sh to swap in the stub engine
/// while working on the simulator.
class OcrEngine {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  static const bool isAvailable = true;

  Future<String> recognize(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  void dispose() {
    _recognizer.close();
  }
}
