import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "screens/connection_screen.dart";

Future<void> main() async {
  await dotenv.load();
  runApp(const LocalLlama());
}

class LocalLlama extends StatelessWidget {
  const LocalLlama({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Local Llama Home Chat",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConnectionScreen(),
    );
  }
}
