import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hisab_khata/core/constants/system_prompt.dart';

class ChatbotService {
  Future<String> get _apiKey async {
    await dotenv.load(fileName: ".env");
    return dotenv.env['APIKEY'] ?? '';
  }

  final String _baseUrl = 'https://openrouter.ai/api/v1';

  Future<String> sendMessage(String message) async {
    final apiKey = await _apiKey;
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'mistralai/devstral-2512:free',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }

  Stream<String> sendMessageStream(String message) async* {
    final apiKey = await _apiKey;
    final request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/chat/completions'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer': '',
      'X-Title': '',
    });
    request.body = jsonEncode({
      'model': 'mistralai/devstral-2512:free',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': message},
      ],
      'stream': true,
    });

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      await for (final chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              return;
            }
            try {
              final jsonData = jsonDecode(data);
              final content = jsonData['choices'][0]['delta']['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } else {
      throw Exception('Failed to get response: ${streamedResponse.statusCode}');
    }
  }
}
