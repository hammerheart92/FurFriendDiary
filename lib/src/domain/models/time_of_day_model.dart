import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'time_of_day_model.g.dart';

@HiveType(typeId: 10)
class TimeOfDayModel extends HiveObject {
  @HiveField(0)
  int hour;

  @HiveField(1)
  int minute;

  TimeOfDayModel({
    required this.hour,
    required this.minute,
  });

  factory TimeOfDayModel.fromTimeOfDay(TimeOfDay timeOfDay) {
    return TimeOfDayModel(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  Map<String, dynamic> toJson() => {
    'hour': hour,
    'minute': minute,
  };

  factory TimeOfDayModel.fromJson(Map<String, dynamic> json) {
  final hour = json['hour'] as int;
  final minute = json['minute'] as int;
  
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw ArgumentError('Invalid time values: hour=$hour, minute=$minute');
  }
  
  return TimeOfDayModel(hour: hour, minute: minute);
}

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String format12Hour() {
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    final hour12 = timeOfDay.hourOfPeriod;
    return '${hour12.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  TimeOfDayModel copyWith({
    int? hour,
    int? minute,
  }) {
    return TimeOfDayModel(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDayModel &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => 'TimeOfDayModel(hour: $hour, minute: $minute)';
}