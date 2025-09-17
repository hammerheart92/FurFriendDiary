import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'walk.g.dart';

@HiveType(typeId: 3) // Make sure this doesn't conflict with your existing typeIds
@JsonSerializable()
class Walk extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String petId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime? endTime;

  @HiveField(4)
  final Duration? duration;

  @HiveField(5)
  final double? distance; // in kilometers

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final WalkType walkType;

  @HiveField(8)
  final DateTime createdAt;

  Walk({
    required this.id,
    required this.petId,
    required this.startTime,
    this.endTime,
    this.duration,
    this.distance,
    this.notes,
    this.walkType = WalkType.regular,
    required this.createdAt,
  });

  factory Walk.fromJson(Map<String, dynamic> json) => _$WalkFromJson(json);
  Map<String, dynamic> toJson() => _$WalkToJson(this);

  // Helper methods
  bool get isActive => endTime == null;
  bool get isComplete => endTime != null;
  
  Duration get actualDuration {
    if (duration != null) return duration!;
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  String get formattedDuration {
    final d = actualDuration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedDistance {
    if (distance == null) return 'Not recorded';
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m';
    }
    return '${distance!.toStringAsFixed(1)}km';
  }

  Walk copyWith({
    String? id,
    String? petId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    double? distance,
    String? notes,
    WalkType? walkType,
    DateTime? createdAt,
  }) {
    return Walk(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
      walkType: walkType ?? this.walkType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 4) // Make sure this doesn't conflict with your existing typeIds
enum WalkType {
  @HiveField(0)
  regular,
  
  @HiveField(1)
  short,
  
  @HiveField(2)
  long,
  
  @HiveField(3)
  training;

  String get displayName {
    switch (this) {
      case WalkType.regular:
        return 'Regular';
      case WalkType.short:
        return 'Short';
      case WalkType.long:
        return 'Long';
      case WalkType.training:
        return 'Training';
    }
  }

  String get icon {
    switch (this) {
      case WalkType.regular:
        return '🚶‍♂️';
      case WalkType.short:
        return '🏃‍♂️';
      case WalkType.long:
        return '🥾';
      case WalkType.training:
        return '🎯';
    }
  }
}