// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class GeminiService {
//   final String apiKey = 'AIzaSyCpKtk-sRhN8A5QoUkDz352MNzHUfqzCwg';

//   Future<bool> isHealthcareRelated(String message) async {
//     final String apiUrl =
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "contents": [
//           {
//             "role": "user",
//             "parts": [
//               {
//                 "text":
//                     "Is the following message healthcare related or about medicine, health, related to body? If it's about medicine, provide a detailed answer. Otherwise, reply with only true or false: $message"
//               }
//             ]
//           }
//         ]
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       String result =
//           data["candidates"][0]["content"]["parts"][0]["text"].toLowerCase();
//       return result.contains('true');
//     }
//     return false;
//   }

//   Future<String> sendMessage(String userMessage) async {
//     bool isHealthcare = await isHealthcareRelated(userMessage);

//     if (!isHealthcare) {
//       return "I can only respond to healthcare-related questions. Please ask something about health, medical treatment, or healthcare services.";
//     }

//     final String apiUrl =
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "contents": [
//           {
//             "role": "user",
//             "parts": [
//               {"text": userMessage}
//             ]
//           }
//         ]
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       String reply = data["candidates"][0]["content"]["parts"][0]["text"];
//       return reply.replaceAll(RegExp(r'[\*]'), '').trim(); // Remove '*' and trim whitespace
//     } else {
//       return "Error: ${response.body}";
//     }
//   }

//   sendMessageStream(String userMessage) {}
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class GeminiService {
  final String apiKey = 'AIzaSyCpKtk-sRhN8A5QoUkDz352MNzHUfqzCwg';
  static const String _disclaimer =
      '\n\n⚠️ Disclaimer: This is not medical advice. Always consult a qualified healthcare professional before taking any medication.';

  Future<bool> isHealthcareRelated(String message) async {
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final String prompt = '''
Is this health-related? Consider: symptoms, diseases, medications, health questions.
Message: "$message"
Reply ONLY with "true" or "false".
''';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String result = data["candidates"][0]["content"]["parts"][0]["text"]
          .toLowerCase()
          .trim();
      return result == 'true';
    }
    return false;
  }

  Future<String> sendMessage(String userMessage) async {
    bool isHealthcare = await isHealthcareRelated(userMessage);

    if (!isHealthcare) {
      return "I can only respond to healthcare-related questions. Please ask something about health, medical treatment, or healthcare services.";
    }

    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final String prompt = '''
For: "$userMessage"
Format your response EXACTLY as follows:

📋 DISEASE OVERVIEW

• Condition: [Name]
• Description: [Brief explanation]
• Key Symptoms: [List main symptoms]

🔄 HEALING PROCESS

1. Immediate Actions:
   • [Action 1]
   • [Action 2]

2. Lifestyle Changes:
   • [Change 1]
   • [Change 2]

3. Prevention:
   • [Prevention 1]
   • [Prevention 2]

💊 MEDICATION GUIDE

1. Common Medications:
   • [Medication 1] - [Purpose]
   • [Medication 2] - [Purpose]

2. Side Effects:
   • [Common side effect 1]
   • [Common side effect 2]

3. Important Warnings:
   ⚠️ [Warning 1]
   ⚠️ [Warning 2]

Keep each point brief and clear. Use this exact format with the separators and emojis.
''';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String reply = data["candidates"][0]["content"]["parts"][0]["text"];
      return '${reply.trim()}$_disclaimer';
    } else {
      return "Error: ${response.body}";
    }
  }

  Stream<String> sendMessageStream(String userMessage) async* {
    bool isHealthcare = await isHealthcareRelated(userMessage);

    if (!isHealthcare) {
      yield "I can only respond to healthcare-related questions. Please ask something about health, medical treatment, or healthcare services.";
      return;
    }

    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?key=$apiKey';

    final String prompt = '''
For: "$userMessage"
Format your response EXACTLY as follows:

📋 DISEASE OVERVIEW

• Condition: [Name]
• Description: [Brief explanation]
• Key Symptoms: [List main symptoms]

🔄 HEALING PROCESS

1. Immediate Actions:
   • [Action 1]
   • [Action 2]

2. Lifestyle Changes:
   • [Change 1]
   • [Change 2]

3. Prevention:
   • [Prevention 1]
   • [Prevention 2]

💊 MEDICATION GUIDE

1. Common Medications:
   • [Medication 1] - [Purpose]
   • [Medication 2] - [Purpose]

2. Side Effects:
   • [Common side effect 1]
   • [Common side effect 2]

3. Important Warnings:
   ⚠️ [Warning 1]
   ⚠️ [Warning 2]

Keep each point brief and clear. Use this exact format with the separators and emojis.
''';

    final requestBody = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      String accumulatedResponse = '';

      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          try {
            final data = jsonDecode(line);
            if (data.containsKey('candidates')) {
              String chunk =
                  data["candidates"][0]["content"]["parts"][0]["text"];
              accumulatedResponse += chunk;
              yield accumulatedResponse.trim();
            }
          } catch (e) {
            continue;
          }
        }
      }
      yield '$accumulatedResponse$_disclaimer';
    } else {
      yield "Error: ${response.body}";
    }
  }
}
