import 'package:flutter/material.dart';

/// Model for walk entries - keep in this file for easy integration
class WalkEntry {
  WalkEntry({
    required this.start,
    required this.durationMin,
    required this.distanceKm,
    this.note,
    this.surface,
    this.paceMinPerKm,
  });

  final DateTime start;
  final int durationMin;
  final double distanceKm;
  final String? note;
  final String? surface;
  final double? paceMinPerKm;
}

/// In-memory controller for walks that survives widget rebuilds
class WalksController extends ChangeNotifier {
  WalksController() {
    // Initialize with mock data
    _items.addAll([
      WalkEntry(
        start: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        durationMin: 32,
        distanceKm: 2.4,
        note: 'City Park loop',
        surface: 'paved',
        paceMinPerKm: 13,
      ),
      WalkEntry(
        start: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        durationMin: 45,
        distanceKm: 3.1,
        note: 'Evening stroll by the river',
        surface: 'mixed',
        paceMinPerKm: 14,
      ),
      WalkEntry(
        start: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
        durationMin: 28,
        distanceKm: 1.9,
        note: 'Quick break between showers',
        surface: 'gravel',
        paceMinPerKm: 15,
      ),
    ]);
  }

  final List<WalkEntry> _items = [];
  
  /// Read-only access to walks list
  List<WalkEntry> get items => List.unmodifiable(_items);
  
  /// Add a new walk and notify listeners (inserts at top for newest-first)
  void add(WalkEntry entry) {
    _items.insert(0, entry);
    notifyListeners();
  }
  
  /// Clear all walks (for testing)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// InheritedNotifier that provides WalksController to descendant widgets
class WalksScope extends InheritedNotifier<WalksController> {
  const WalksScope({
    super.key,
    required WalksController super.notifier,
    required super.child,
  });

  /// Convenience method to get the controller from context
  static WalksController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WalksScope>();
    assert(scope != null, 'WalksScope not found in widget tree');
    return scope!.notifier!;
  }
}
