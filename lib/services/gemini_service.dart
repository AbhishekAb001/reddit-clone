import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  static String sanitizeResponse(String text) {
    // Remove any non-printable characters
    text = text.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');

    // Replace multiple spaces with single space
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Remove any remaining special characters that might cause display issues
    text = text.replaceAll(RegExp(r'[^\x20-\x7E\s]'), '');

    return text.trim();
  }

  static Future<Stream<String>> getResponse(String prompt) async {
    try {
      final formattedPrompt = '''
Please respond in clear, grammatically correct English.
Use proper formatting and avoid any special characters.
Here is the request: $prompt
''';

      final stream = Gemini.instance.promptStream(
        parts: [Part.text(formattedPrompt)],
      );

      return stream.map((response) {
        if (response?.output != null) {
          return sanitizeResponse(response!.output!);
        }
        return '';
      });
    } catch (e) {
      throw Exception('Failed to get response: $e');
    }
  }
}
