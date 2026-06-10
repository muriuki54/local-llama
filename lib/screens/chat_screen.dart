import "package:flutter/material.dart";
import "../services/ollama_service.dart";
import "../widgets/chat_bubble.dart";
import "connection_screen.dart";

class ChatScreen extends StatefulWidget {
  final String serverUrl;
  final bool showBackButton;

  const ChatScreen({
    super.key,
    required this.serverUrl,
    this.showBackButton = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late OllamaService _ollamaService;

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _ollamaService = OllamaService(baseUrl: widget.serverUrl, model: "mistral");
  }

  String _timeNow() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, "0");
    final period = now.period == DayPeriod.am ? "AM" : "PM";

    return "$hour:$minute $period";
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"role": "user", "content": message, "time": _timeNow()});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final apiMessages = _messages
          .map(
            (message) => {
              "role": message["role"]!,
              "content": message["content"]!,
            },
          )
          .toList();

      final reply = await _ollamaService.sendMessage(apiMessages);

      setState(() {
        _messages.add({
          "role": "assistant",
          "content": reply,
          "time": _timeNow(),
        });
      });
    } catch (e, stackTrace) {
      debugPrint("=== LOCAL LLAMA ERROR ===");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      setState(() {
        _messages.add({
          "role": "assistant",
          "content":
              "Could not connect to Local Llama. Please check your server.",
          "time": _timeNow(),
        });
      });
    }

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<void> _testConnection() async {
    final isConnected = await _ollamaService.testConnection();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isConnected
              ? "Local Llama is online."
              : "Could not connect to Local Llama.",
        ),
      ),
    );
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  void _showServerInfo() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Server Info"),
          content: Text(
            "App: Local Llama\n"
            "Server: ${widget.serverUrl}\n"
            "Model: mistral\n"
            "Status: Local network only",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$feature will be added in the next version.")),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        margin: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 44, color: Color(0xFF6C4DFF)),
            SizedBox(height: 14),
            Text(
              "Start a conversation",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Ask Local Llama anything from your home network.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("Mistral is thinking..."),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C4DFF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Local Llama",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.serverUrl,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) {
              if (value == "clear") {
                _clearChat();
              } else if (value == "model") {
                _showComingSoon("Change Model");
              } else if (value == "info") {
                _showServerInfo();
              } else if (value == "test") {
                _testConnection();
              } else if (value == "settings") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ConnectionScreen()),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "clear",
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text("Clear Chat"),
                ),
              ),
              PopupMenuItem(
                value: "model",
                child: ListTile(
                  leading: Icon(Icons.view_in_ar_outlined),
                  title: Text("Change Model"),
                ),
              ),
              PopupMenuItem(
                value: "info",
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Server Info"),
                ),
              ),
              PopupMenuItem(
                value: "test",
                child: ListTile(
                  leading: Icon(Icons.wifi),
                  title: Text("Test Connection"),
                ),
              ),
              PopupMenuItem(
                value: "settings",
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Settings"),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return _buildLoadingBubble();
                      }

                      final message = _messages[index];

                      return ChatBubble(
                        role: message["role"] ?? "assistant",
                        content: message["content"] ?? "",
                        time: message["time"] ?? "",
                      );
                    },
                  ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFC),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Ask something...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    height: 52,
                    width: 52,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
