import "dart:convert";
import "package:http/http.dart" as http;

class OllamaService {
  final String baseUrl;
  final String model;

  OllamaService({required this.baseUrl, this.model = "mistral"});

  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/tags"))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> sendMessage(String message) async {
    final url = Uri.parse("$baseUrl/api/chat");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "model": model,
        "messages": [
          {"role": "user", "content": message},
        ],
        "stream": false,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Ollama error: ${response.body}");
    }

    final data = jsonDecode(response.body);

    return data["message"]["content"] ?? "No response received.";
  }
}
