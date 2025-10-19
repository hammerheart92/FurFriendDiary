// lib/layout/app_page.dart
import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;

  const AppPage({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
