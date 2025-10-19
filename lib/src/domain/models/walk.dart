import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'walk.g.dart';

@HiveType(typeId: 3)
class Walk extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  DateTime start;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  double? distance;

  @HiveField(6)
  WalkType walkType;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  bool isComplete;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  DateTime startTime;

  @HiveField(11)
  List<WalkLocation>? locations;

  Walk({
    String? id,
    required this.petId,
    required this.start,
    this.endTime,
    required this.durationMinutes,
    this.distance,
    this.walkType = WalkType.walk,
    this.isActive = false,
    this.isComplete = false,
    this.notes,
    DateTime? startTime,
    this.locations,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? start;

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'start': start.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'durationMinutes': durationMinutes,
        'distance': distance,
        'walkType': walkType.toString(),
        'isActive': isActive,
        'isComplete': isComplete,
        'notes': notes,
        'startTime': startTime.toIso8601String(),
        'locations': locations?.map((l) => l.toJson()).toList(),
      };

  factory Walk.fromJson(Map<String, dynamic> json) => Walk(
        id: json['id'],
        petId: json['petId'],
        start: DateTime.parse(json['start']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        durationMinutes: json['durationMinutes'],
        distance: (json['distance'] as num?)?.toDouble(),
        walkType: WalkType.values.firstWhere(
          (e) => e.toString() == json['walkType'],
          orElse: () => WalkType.walk,
        ),
        isActive: json['isActive'] ?? false,
        isComplete: json['isComplete'] ?? false,
        notes: json['notes'],
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'])
            : null,
        locations: json['locations']
            ?.map<WalkLocation>((l) => WalkLocation.fromJson(l))
            .toList(),
      );

  Walk copyWith({
    String? id,
    String? petId,
    DateTime? start,
    DateTime? endTime,
    int? durationMinutes,
    double? distance,
    WalkType? walkType,
    bool? isActive,
    bool? isComplete,
    String? notes,
    DateTime? startTime,
    List<WalkLocation>? locations,
  }) {
    return Walk(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      start: start ?? this.start,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distance: distance ?? this.distance,
      walkType: walkType ?? this.walkType,
      isActive: isActive ?? this.isActive,
      isComplete: isComplete ?? this.isComplete,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      locations: locations ?? this.locations,
    );
  }

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedDistance {
    if (distance == null) return 'N/A';
    return '${distance!.toStringAsFixed(2)} km';
  }

  Duration? get actualDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  // For backward compatibility
  double? get distanceKm => distance;
}

@HiveType(typeId: 4)
enum WalkType {
  @HiveField(0)
  walk,
  @HiveField(1)
  run,
  @HiveField(2)
  hike,
  @HiveField(3)
  play,
  @HiveField(4)
  regular,
  @HiveField(5)
  short,
  @HiveField(6)
  long,
  @HiveField(7)
  training,
}

extension WalkTypeExtension on WalkType {
  String get displayName {
    switch (this) {
      case WalkType.walk:
        return 'Walk';
      case WalkType.run:
        return 'Run';
      case WalkType.hike:
        return 'Hike';
      case WalkType.play:
        return 'Play';
      case WalkType.regular:
        return 'Regular Walk';
      case WalkType.short:
        return 'Short Walk';
      case WalkType.long:
        return 'Long Walk';
      case WalkType.training:
        return 'Training';
    }
  }

  String get icon {
    switch (this) {
      case WalkType.walk:
        return '🚶';
      case WalkType.run:
        return '🏃';
      case WalkType.hike:
        return '🥾';
      case WalkType.play:
        return '🎾';
      case WalkType.regular:
        return '🚶';
      case WalkType.short:
        return '⚡';
      case WalkType.long:
        return '🏃‍♂️';
      case WalkType.training:
        return '🎯';
    }
  }
}

@HiveType(typeId: 7)
class WalkLocation extends HiveObject {
  @HiveField(0)
  double latitude;

  @HiveField(1)
  double longitude;

  @HiveField(2)
  DateTime timestamp;

  WalkLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WalkLocation.fromJson(Map<String, dynamic> json) => WalkLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
      );
}
