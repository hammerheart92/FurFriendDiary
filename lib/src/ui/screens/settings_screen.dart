
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Premium'),
            subtitle: const Text('Upgrade to unlock advanced features'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/premium'),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable analytics'),
            value: false,
            onChanged: (_) {},
          ),
          ListTile(
            title: const Text('Privacy policy'),
            onTap: (){} ,
          ),
        ],
      ),
    );
  }
}
