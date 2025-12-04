import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyCvpv9P-ENn9CHI77TpNKdiKApNXdbJ8sc';
  static GenerativeModel? _model;

  static GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash', // or gemini-2.0-flash-exp when available
      apiKey: apiKey,
    );
    return _model!;
  }

  // Clean any markdown symbols from Gemini's response
  static String _cleanResponse(String text) {
    if (text.isEmpty) return text;

    return text
        .replaceAll(RegExp(r'\*\*|\*|\#+|--+|\_{2,}|~{2,}'), '') // Remove **, *, ###, ---, __, ~~
        .replaceAll(RegExp(r'^\s*[-*•]\s+', multiLine: true), '• ') // Clean bullets
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n') // Remove extra blank lines
        .trim();
  }

  static Future<String> getArticleDetails(String headline, String url) async {
    try {
      final prompt = '''
You are a professional news analyst for a premium news app.

Analyze this headline and provide a clean, beautifully formatted response with NO markdown symbols like **, *, #, -, etc.

Use this exact clean structure:

Summary
[2-3 short sentences explaining the news]

Key Points
• Point one
• Point two  
• Point three

Background
[1-2 sentences of context]

Why It Matters
[1 powerful sentence]

Keep total response under 180 words. Be concise, professional, and natural.

Headline: $headline
Source: $url
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final rawText = response.text ?? 'No details available.';
      return _cleanResponse(rawText);
    } catch (e) {
      return 'Unable to load insights at this time.';
    }
  }

  static Future<String> getChainSummary(String chainHeadlines) async {
    try {
      final prompt = '''
You are a senior news editor summarizing a developing story for a premium news app.

From the headlines below, write a clean, professional summary with ZERO markdown symbols (no **, *, #, -, etc.).

Use this exact clean structure:

Story Evolution
[2-3 sentences describing how the narrative changed over time]

Key Developments
• First major update
• Second turning point
• Most recent shift

Current Status
[1 clear sentence]

Significance
[1 sentence on broader impact]

Keep total under 150 words. Write naturally and elegantly.

Headlines (chronological):
$chainHeadlines
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final rawText = response.text ?? 'No summary available.';
      return _cleanResponse(rawText);
    } catch (e) {
      return 'Unable to generate story summary.';
    }
  }
}