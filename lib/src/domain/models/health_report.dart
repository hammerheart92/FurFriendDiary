import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'health_report.g.dart';

const _uuid = Uuid();

@HiveType(typeId: 20)
class HealthReport extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  DateTime generatedDate;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  @HiveField(5)
  double healthScore; // 0-100

  @HiveField(6)
  Map<String, dynamic> metrics; // JSON data

  @HiveField(7)
  String? notes;

  HealthReport({
    String? id,
    required this.petId,
    required this.generatedDate,
    required this.startDate,
    required this.endDate,
    required this.healthScore,
    required this.metrics,
    this.notes,
  }) : id = id ?? _uuid.v4();

  HealthReport copyWith({
    String? id,
    String? petId,
    DateTime? generatedDate,
    DateTime? startDate,
    DateTime? endDate,
    double? healthScore,
    Map<String, dynamic>? metrics,
    String? notes,
  }) {
    return HealthReport(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      generatedDate: generatedDate ?? this.generatedDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      healthScore: healthScore ?? this.healthScore,
      metrics: metrics ?? this.metrics,
      notes: notes ?? this.notes,
    );
  }
}
