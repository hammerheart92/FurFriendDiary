
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Package import (preferred)
import 'package:fur_friend_diary/features/walks/walks_screen.dart' as walks;
// Relative import fallback: import '../../../features/walks/walks_screen.dart' as walks;
import 'package:fur_friend_diary/features/walks/walks_state.dart';
// Relative import fallback: import '../../../features/walks/walks_state.dart';

class WalksScreen extends ConsumerStatefulWidget {
  const WalksScreen({super.key});

  @override
  ConsumerState<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends ConsumerState<WalksScreen> with AutomaticKeepAliveClientMixin {
  late final WalksController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Initialize controller with default pet ID
    _controller = WalksController('default-pet-id');
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
