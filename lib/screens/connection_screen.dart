import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../services/ollama_service.dart";
import "../widgets/info_card.dart";
import "connection_success_screen.dart";

class ConnectionScreen extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onConnected;

  const ConnectionScreen({
    super.key,
    this.showBackButton = true,
    this.onConnected,
  });

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _serverController = TextEditingController();

  String _selectedModel = "mistral";

  final List<String> _models = ["mistral", "llama3.2"];

  bool _isTesting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedServer();
  }

  Future<void> _loadSavedServer() async {
    final prefs = await SharedPreferences.getInstance();

    _serverController.text =
        prefs.getString("local_llama_server_url") ??
        "http://192.168.1.253:11434";

    _selectedModel = prefs.getString("local_llama_model") ?? "mistral";

    setState(() {});
  }

  Future<void> _testConnection() async {
    final serverUrl = _serverController.text.trim();

    if (serverUrl.isEmpty) {
      setState(() {
        _error = "Enter your Local Llama server URL.";
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _error = null;
    });

    final service = OllamaService(baseUrl: serverUrl, model: _selectedModel);
    final isConnected = await service.testConnection();

    setState(() {
      _isTesting = false;
    });

    if (!isConnected) {
      setState(() {
        _error = "Could not connect to server. Check the URL and try again.";
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("local_llama_model", _selectedModel);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConnectionSuccessScreen(
          serverUrl: serverUrl,
          model: _selectedModel,
          onStartChat: widget.onConnected,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C4DFF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Connection"),
        backgroundColor: purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: widget.showBackButton,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 32),

              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.pets, size: 42, color: purple),
              ),

              const SizedBox(height: 22),

              const Text(
                "Local Llama",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Connect to your Ollama server on your home network.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),

              const SizedBox(height: 36),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ollama Server URL",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _serverController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: "http://192.168.1.253:11434",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Example: http://192.168.1.253:11434",
                  style: TextStyle(color: Colors.black54),
                ),
              ),

              // Select model
              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Model",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedModel,
                items: _models.map((model) {
                  return DropdownMenuItem(value: model, child: Text(model));
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedModel = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              // End select model
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_rounded),
                  label: Text(
                    _isTesting ? "Testing..." : "Test Connection",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_error!)),
                    ],
                  ),
                ),

              if (_error != null) const SizedBox(height: 20),

              const InfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}
