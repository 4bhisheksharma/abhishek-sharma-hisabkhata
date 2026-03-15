import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hisab_khata/core/constants/system_prompt.dart';
import 'package:http/http.dart' as http;

/// Service that takes raw OCR text and uses an AI model to extract
/// structured transaction details (amount, description).
class OcrAiRefinerService {
  static const String _ocrModel = 'nvidia/nemotron-3-nano-30b-a3b:free';

  static String get _apiKey => dotenv.env['APIKEYOCR'] ?? '';
  static String get _baseUrl =>
      dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';

  /// Sends OCR-extracted text to the AI model and returns a refined
  /// [RefinedTransaction] with amount and description.
  /// Returns null if refinement fails.
  static Future<RefinedTransaction?> refine(String ocrText) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _ocrModel,
          'messages': [
            {'role': 'system', 'content': systemPromptForOcr},
            {'role': 'user', 'content': ocrText},
          ],
          'temperature': 0.1,
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      if (content == null || content.isEmpty) return null;

      return _parseAiResponse(content);
    } catch (_) {
      return null;
    }
  }

  /// Parse the AI response JSON into a [RefinedTransaction].
  static RefinedTransaction? _parseAiResponse(String content) {
    try {
      // The AI might wrap JSON in markdown code fences — strip them.
      String cleaned = content.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned
            .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
            .replaceFirst(RegExp(r'```\s*$'), '')
            .trim();
      }

      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final amount = _extractAmount(json['amount']);
      final description = (json['description'] as String?)?.trim() ?? '';

      if (amount == null || amount <= 0 || description.isEmpty) return null;

      return RefinedTransaction(amount: amount, description: description);
    } catch (_) {
      return null;
    }
  }

  static double? _extractAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', ''));
    return null;
  }
}

/// Data class returned by the AI refiner.
class RefinedTransaction {
  final double amount;
  final String description;

  const RefinedTransaction({required this.amount, required this.description});

  @override
  String toString() =>
      'RefinedTransaction(amount: $amount, description: $description)';
}
