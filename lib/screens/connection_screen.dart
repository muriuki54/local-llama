import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../services/ollama_service.dart";
import "chat_screen.dart";

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _serverController = TextEditingController();
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSavedServer();
  }

  Future<void> _loadSavedServer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString("ollama_server_url");

    if (savedUrl != null) {
      _serverController.text = savedUrl;
    } else {
      final defaultUrl =
          dotenv.env["OLLAMA_SERVER_URL"] ?? "http://192.168.1.50:11434";
      _serverController.text = defaultUrl;
    }
  }

  Future<void> _testConnection() async {
    final serverUrl = _serverController.text.trim();

    if (serverUrl.isEmpty) {
      _showMessage("Enter your Ollama server URL");
      return;
    }

    setState(() {
      _isTesting = true;
    });

    final service = OllamaService(baseUrl: serverUrl);
    final isConnected = await service.testConnection();

    setState(() {
      _isTesting = false;
    });

    if (!isConnected) {
      _showMessage("Could not connect to Local Llama");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("ollama_server_url", serverUrl);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(serverUrl: serverUrl)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect to Local Llama")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Enter your Ubuntu server Ollama URL.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: "Ollama Server URL",
                hintText: "http://192.168.1.50:11434",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isTesting ? null : _testConnection,
                child: _isTesting
                    ? const CircularProgressIndicator()
                    : const Text("Test Connection"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
