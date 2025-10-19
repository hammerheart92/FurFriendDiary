import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'report_entry.g.dart';

@HiveType(typeId: 9)
class ReportEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String
      reportType; // 'Health Summary', 'Medication History', 'Activity Report', 'Veterinary Records'

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  @HiveField(5)
  DateTime generatedDate;

  @HiveField(6)
  Map<String, dynamic> data; // Report content data

  @HiveField(7)
  Map<String, dynamic>? filters; // Applied filters

  @HiveField(8)
  DateTime createdAt;

  ReportEntry({
    String? id,
    required this.petId,
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.data,
    this.filters,
    DateTime? generatedDate,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        generatedDate = generatedDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'reportType': reportType,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'generatedDate': generatedDate.toIso8601String(),
        'data': data,
        'filters': filters,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReportEntry.fromJson(Map<String, dynamic> json) => ReportEntry(
        id: json['id'],
        petId: json['petId'],
        reportType: json['reportType'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        generatedDate: json['generatedDate'] != null
            ? DateTime.parse(json['generatedDate'])
            : DateTime.now(),
        data: json['data'] != null
            ? Map<String, dynamic>.from(json['data'] as Map)
            : {},
        filters: json['filters'] != null
            ? Map<String, dynamic>.from(json['filters'] as Map)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  ReportEntry copyWith({
    String? id,
    String? petId,
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? generatedDate,
    Map<String, dynamic>? data,
    Map<String, dynamic>? filters,
    DateTime? createdAt,
  }) {
    return ReportEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      reportType: reportType ?? this.reportType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      generatedDate: generatedDate ?? this.generatedDate,
      data: data ?? this.data,
      filters: filters ?? this.filters,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
