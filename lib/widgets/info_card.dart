import "package:flutter/material.dart";

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Text("Make sure:", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          Text("• Your phone and server are on the same Wi-Fi"),
          Text("• Ollama is running on your server"),
          Text("• Port 11434 is accessible"),
        ],
      ),
    );
  }
}
