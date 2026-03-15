import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'image_transaction_parser.dart';

/// Service to parse OCR-extracted text using an AI model for accurate transaction extraction
class AiTransactionParser {
  static const String _systemPrompt =
      'You are a financial transaction parser. '
      'Analyze the OCR-extracted text from a receipt or bill and identify the single most relevant transaction. '
      'Respond ONLY with a valid JSON object containing exactly two fields: '
      '"amount" (the total/final amount as a number, no currency symbols) and '
      '"description" (a concise 1-5 word summary of what was purchased). '
      'Example: {"amount": 500.00, "description": "Grocery Shopping"}. '
      'If you cannot determine either field, set it to null.';

  /// Parse OCR text using the AI model configured via APIKEYOCR in .env.
  /// Returns a [ParsedImageTransaction] with high confidence on success,
  /// or null if the API is unavailable or parsing fails.
  static Future<ParsedImageTransaction?> parse(String ocrText) async {
    if (ocrText.isEmpty) return null;

    try {
      // Load .env only if not already loaded
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }

      final apiKey = dotenv.env['APIKEYOCR'] ?? '';
      if (apiKey.isEmpty) {
        debugPrint('AiTransactionParser: APIKEYOCR is not set in .env');
        return null;
      }

      final baseUrl =
          dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
      final model = dotenv.env['OPENROUTER_MODEL'] ?? 'openai/gpt-4o-mini';

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                {
                  'role': 'user',
                  'content':
                      'Extract the transaction details from this OCR text:\n\n$ocrText',
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices'][0]['message']['content'] as String? ?? '';
        return _parseAiResponse(content, ocrText);
      } else {
        debugPrint(
          'AiTransactionParser: API returned status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('AiTransactionParser: error during API call – $e');
    }

    return null;
  }

  /// Extract [ParsedImageTransaction] from the AI's JSON response string.
  static ParsedImageTransaction? _parseAiResponse(
    String content,
    String originalText,
  ) {
    try {
      // Locate JSON boundaries in case the model wraps the object in prose
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd < jsonStart) {
        debugPrint('AiTransactionParser: no JSON object found in response');
        return null;
      }

      final jsonStr = content.substring(jsonStart, jsonEnd + 1);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final amount = (json['amount'] as num?)?.toDouble();
      final description = (json['description'] as String?)?.trim();

      if (amount == null || amount <= 0) return null;
      if (description == null || description.isEmpty) return null;

      return ParsedImageTransaction(
        amount: amount,
        description: description,
        originalText: originalText,
        confidence: 0.95,
      );
    } catch (e) {
      debugPrint('AiTransactionParser: failed to parse AI response – $e');
      return null;
    }
  }
}
