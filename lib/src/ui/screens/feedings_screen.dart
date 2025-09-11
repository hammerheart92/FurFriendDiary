
import 'package:flutter/material.dart';

class FeedingsScreen extends StatelessWidget {
  const FeedingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Feedings') ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('This is a placeholder. Add forms, lists, and actions here.'),
      ],
    ),
  );
}
