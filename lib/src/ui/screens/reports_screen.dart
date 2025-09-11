
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reports') ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('This is a placeholder. Add forms, lists, and actions here.'),
      ],
    ),
  );
}
