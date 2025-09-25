import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../src/domain/models/walk.dart';
import '../../src/data/local/hive_manager.dart';

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

  /// Convert WalkEntry to the full Walk model for Hive persistence
  Walk toWalk({required String petId}) {
    return Walk(
      petId: petId,
      start: start,
      startTime: start,
      durationMinutes: durationMin,
      distance: distanceKm,
      notes: note,
      walkType: _mapSurfaceToWalkType(),
      isActive: false,
      isComplete: true,
    );
  }

  /// Convert full Walk model to WalkEntry for UI display
  static WalkEntry fromWalk(Walk walk) {
    return WalkEntry(
      start: walk.startTime,
      durationMin: walk.durationMinutes,
      distanceKm: walk.distance ?? 0.0,
      note: walk.notes,
      surface: _mapWalkTypeToSurface(walk.walkType),
      paceMinPerKm: walk.distance != null && walk.durationMinutes > 0 
          ? walk.durationMinutes / walk.distance!
          : null,
    );
  }

  WalkType _mapSurfaceToWalkType() {
    switch (surface) {
      case 'paved':
        return WalkType.regular;
      case 'gravel':
        return WalkType.hike;
      case 'mixed':
        return WalkType.walk;
      default:
        return WalkType.regular;
    }
  }

  static String? _mapWalkTypeToSurface(WalkType walkType) {
    switch (walkType) {
      case WalkType.regular:
        return 'paved';
      case WalkType.hike:
        return 'gravel';
      case WalkType.walk:
        return 'mixed';
      default:
        return 'paved';
    }
  }
}

/// Enhanced controller that bridges ChangeNotifier UI with Hive persistence
class WalksController extends ChangeNotifier {
  final logger = Logger();
  final String _defaultPetId;
  
  WalksController(this._defaultPetId) {
    _initializeWalks();
  }

  /// Initialize walks with immediate mock data, then try to load from storage
  Future<void> _initializeWalks() async {
    logger.i('🚀 INITIALIZING WalksController...');
    
    try {
      // First, add mock data immediately for UI responsiveness
      _addMockData();
      
      // Then try to load real data from storage
      await _loadWalksFromHive();
    } catch (e) {
      logger.e('❌ Error during initialization: $e');
      // Ensure we have at least mock data for UI testing
      if (_items.isEmpty) {
        _addMockData();
      }
    }
  }

  final List<WalkEntry> _items = [];
  
  /// Read-only access to walks list
  List<WalkEntry> get items => List.unmodifiable(_items);
  
  /// Load walks from Hive storage and convert to WalkEntry
  Future<void> _loadWalksFromHive() async {
    logger.i('🔄 ATTEMPTING to load walks from Hive...');
    try {
      // Get the properly typed walks box
      final walkBox = HiveManager.instance.walkBox;
      final walks = walkBox.values.toList();
      
      logger.i('📚 DIRECT HIVE: Found ${walks.length} walks in storage');
      
      if (walks.isNotEmpty) {
        _items.clear();
        // Convert Walk objects to WalkEntry objects
        for (var walk in walks) {
          try {
            _items.add(WalkEntry.fromWalk(walk));
          } catch (e) {
            logger.w('⚠️  Failed to convert walk: $e');
          }
        }
        logger.i('✅ LOADED ${_items.length} walks from storage');
        notifyListeners();
      } else {
        logger.i('📝 No walks in storage, keeping mock data');
      }
    } catch (e) {
      logger.e('❌ Error loading from storage: $e');
      logger.i('📝 Keeping mock data as fallback');
    }
  }
  
  /// Add mock data as fallback
  void _addMockData() {
    logger.i('📝 Adding mock data as fallback');
    final now = DateTime.now();
    _items.clear();
    _items.addAll([
      WalkEntry(
        start: now.subtract(const Duration(minutes: 30)), // 30 minutes ago
        durationMin: 32,
        distanceKm: 2.4,
        note: 'City Park loop',
        surface: 'paved',
        paceMinPerKm: 13,
      ),
      WalkEntry(
        start: now.subtract(const Duration(hours: 2)), // 2 hours ago (today)
        durationMin: 45,
        distanceKm: 3.1,
        note: 'Evening stroll by the river',
        surface: 'mixed',
        paceMinPerKm: 14,
      ),
      WalkEntry(
        start: now.subtract(const Duration(days: 2)), // 2 days ago (this week)
        durationMin: 28,
        distanceKm: 1.9,
        note: 'Quick break between showers',
        surface: 'gravel',
        paceMinPerKm: 15,
      ),
    ]);
    logger.i('📝 Mock data added: ${_items.length} walks with dates:');
    for (var item in _items) {
      logger.d('   - "${item.note}" at ${item.start}');
    }
    notifyListeners();
  }
  
  /// Add a new walk and save to both UI state and Hive persistence
  Future<void> add(WalkEntry entry) async {
    logger.i('🚶 ADDING walk: ${entry.note} at ${entry.start}');
    
    try {
      // 1. Add to UI state immediately for instant feedback
      _items.insert(0, entry);
      notifyListeners();
      logger.i('✅ Walk added to UI state');
      
      // 2. Save to Hive storage for persistence
      final walk = entry.toWalk(petId: _defaultPetId);
      
      // Save directly to Hive storage
      await _saveToHive(walk);
      logger.i('💾 Walk saved to Hive storage');
      
    } catch (e) {
      logger.e('❌ Error saving walk: $e');
      // Keep the UI state since user sees the confirmation
    }
  }
  
  /// Save walk directly to Hive
  Future<void> _saveToHive(Walk walk) async {
    try {
      final walkBox = HiveManager.instance.walkBox;
      await walkBox.put(walk.id, walk);
      logger.i('💽 Walk ${walk.id} saved to Hive');
    } catch (e) {
      logger.e('❌ Error saving to Hive: $e');
      rethrow;
    }
  }
  
  /// Refresh walks from storage (useful after app restart)
  Future<void> refresh() async {
    logger.i('🔄 REFRESHING walks from storage...');
    await _loadWalksFromHive();
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
