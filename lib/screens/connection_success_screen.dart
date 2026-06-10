import "package:flutter/material.dart";
import "chat_screen.dart";
import "connection_screen.dart";

class ConnectionSuccessScreen extends StatelessWidget {
  final String serverUrl;
  final VoidCallback? onStartChat;
  final String model;

  const ConnectionSuccessScreen({
    super.key,
    required this.serverUrl,
    required this.model,
    this.onStartChat,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C4DFF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connection Success"),
        backgroundColor: purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 54,
                  color: Colors.green.shade700,
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                "Connected!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Successfully connected to Local Llama.",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.dns_outlined,
                      title: "Server URL",
                      value: serverUrl,
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.view_in_ar_outlined,
                      title: "Model",
                      value: model,
                    ),
                    const Divider(height: 1),
                    const _InfoRow(
                      icon: Icons.schedule_outlined,
                      title: "Status",
                      value: "Ready",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    if (onStartChat != null) {
                      Navigator.pop(context);
                      onStartChat!();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(serverUrl: serverUrl, model: model),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Start Chat"),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConnectionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Change Server"),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
    );
  }
}
