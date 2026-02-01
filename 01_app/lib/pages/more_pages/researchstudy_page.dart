import 'package:flutter/material.dart';

class ResearchStudyPage extends StatelessWidget {
  const ResearchStudyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Research Study")),
      body: const Center(child: Text("Study Information Here")),
    );
  }
}