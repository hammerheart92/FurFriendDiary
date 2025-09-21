
import 'package:flutter/material.dart';
// Package import (preferred)
import 'package:fur_friend_diary/features/walks/walks_screen.dart' as walks;
// Relative import fallback: import '../../../features/walks/walks_screen.dart' as walks;
import 'package:fur_friend_diary/features/walks/walks_state.dart';
// Relative import fallback: import '../../../features/walks/walks_state.dart';

class WalksScreen extends StatefulWidget {
  const WalksScreen({super.key});

  @override
  State<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends State<WalksScreen> with AutomaticKeepAliveClientMixin {
  late final WalksController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = WalksController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return WalksScope(
      notifier: _controller,
      child: const walks.WalksScreen(),
    );
  }
}
