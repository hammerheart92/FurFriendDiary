
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Appointments') ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('This is a placeholder. Add forms, lists, and actions here.'),
      ],
    ),
  );
}
