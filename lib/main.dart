import "package:flutter/material.dart";
import "screens/app_shell.dart";

void main() {
  runApp(const LocalLlamaApp());
}

class LocalLlamaApp extends StatelessWidget {
  const LocalLlamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C4DFF);

    return MaterialApp(
      title: "Local Llama",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          primary: primaryPurple,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
