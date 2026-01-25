import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service to extract text from images using OCR
class OcrService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from an image file
  /// Returns the extracted text or null if extraction fails
  static Future<String?> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (recognizedText.text.isEmpty) {
        return null;
      }

      return recognizedText.text;
    } catch (e) {
      return null;
    }
  }

  /// Extract text with detailed block information
  /// Returns structured text with blocks and lines
  static Future<OcrResult?> extractTextWithDetails(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (recognizedText.text.isEmpty) {
        return null;
      }

      final List<OcrTextBlock> blocks = [];

      for (final block in recognizedText.blocks) {
        final lines = block.lines
            .map((line) => OcrTextLine(text: line.text))
            .toList();

        blocks.add(OcrTextBlock(text: block.text, lines: lines));
      }

      return OcrResult(fullText: recognizedText.text, blocks: blocks);
    } catch (e) {
      return null;
    }
  }

  /// Dispose of the text recognizer
  static void dispose() {
    _textRecognizer.close();
  }
}

/// Data class for OCR result
class OcrResult {
  final String fullText;
  final List<OcrTextBlock> blocks;

  const OcrResult({required this.fullText, required this.blocks});
}

/// Data class for OCR text block
class OcrTextBlock {
  final String text;
  final List<OcrTextLine> lines;

  const OcrTextBlock({required this.text, required this.lines});
}

/// Data class for OCR text line
class OcrTextLine {
  final String text;

  const OcrTextLine({required this.text});
}
