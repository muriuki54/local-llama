import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class HomeScreen extends StatefulWidget {
  final VoidCallback onStartChat;
  final VoidCallback onTestConnection;

  const HomeScreen({
    super.key,
    required this.onStartChat,
    required this.onTestConnection,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _serverUrl = "http://192.168.1.50:11434";

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _serverUrl =
          prefs.getString("local_llama_server_url") ??
          "http://192.168.1.50:11434";
    });
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C4DFF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Llama"),
        backgroundColor: purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    "assets/images/llama-icon.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Local Llama",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Private AI running on your home server.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.dns_outlined),
                    const SizedBox(height: 8),
                    const Text(
                      "Current Server",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _serverUrl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Model: mistral",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: widget.onStartChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Start Chat"),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: widget.onTestConnection,
                  icon: const Icon(Icons.wifi),
                  label: const Text("Test Connection"),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
