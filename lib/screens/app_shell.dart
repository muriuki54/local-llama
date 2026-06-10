import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "home_screen.dart";
import "connection_screen.dart";
import "chat_screen.dart";

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;
  String _serverUrl = "http://192.168.1.253:11434";
  String _selectedModel = "mistral";

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _serverUrl =
          prefs.getString("local_llama_server_url") ??
          "http://192.168.1.253:11434";

      _selectedModel = prefs.getString("local_llama_model") ?? "mistral";
    });
  }

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _loadServerUrl();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onStartChat: () => _changeTab(2),
        onTestConnection: () => _changeTab(1),
      ),
      ConnectionScreen(showBackButton: false, onConnected: () => _changeTab(2)),
      ChatScreen(
        serverUrl: _serverUrl,
        model: _selectedModel,
        showBackButton: false,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_outlined),
            selectedIcon: Icon(Icons.wifi),
            label: "Test",
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: "Chat",
          ),
        ],
      ),
    );
  }
}
