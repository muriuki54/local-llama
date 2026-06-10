import "dart:convert";
import "package:flutter/cupertino.dart";
import "package:http/http.dart" as http;

class OllamaService {
  final String baseUrl;
  final String model;

  OllamaService({required this.baseUrl, required this.model});

  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/tags"))
          .timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      debugPrint("=== Model: $model ===");

      final response = await http
          .post(
            Uri.parse("$baseUrl/api/chat"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "model": model,
              "messages": messages,
              "stream": false,
            }),
          )
          .timeout(const Duration(minutes: 10));

      if (response.statusCode != 200) {
        throw Exception("Server returned status ${response.statusCode}");
      }

      final data = jsonDecode(response.body);
      return data["message"]?["content"] ?? "No response received.";
    } catch (e) {
      throw Exception("Could not get a response from Local Llama.");
    }
  }
}
