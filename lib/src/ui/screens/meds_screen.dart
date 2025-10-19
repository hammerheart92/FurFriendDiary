import 'package:flutter/material.dart';

class MedsScreen extends StatelessWidget {
  const MedsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Meds')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            Text('This is a placeholder. Add forms, lists, and actions here.'),
          ],
        ),
      );
}
