import 'package:hive/hive.dart';
import '../time_of_day_model.dart';

part 'treatment_plan.g.dart';

/// Represents a veterinary treatment plan for a pet
///
/// A treatment plan is a structured care protocol prescribed by a veterinarian,
/// containing multiple tasks to be completed over a period of time. Plans can
/// be active or inactive and track completion progress.
@HiveType(typeId: 27)
class TreatmentPlan extends HiveObject {
  /// Unique identifier for this treatment plan
  @HiveField(0)
  final String id;

  /// ID of the pet this plan is for
  @HiveField(1)
  final String petId;

  /// Name of the treatment plan (e.g., "Post-Surgery Recovery", "Antibiotic Course")
  @HiveField(2)
  final String name;

  /// Detailed description of the treatment plan
  @HiveField(3)
  final String description;

  /// Name of the veterinarian who created/prescribed this plan
  @HiveField(4)
  final String? veterinarianName;

  /// Date when the treatment plan starts
  @HiveField(5)
  final DateTime startDate;

  /// Date when the treatment plan ends (optional for ongoing plans)
  @HiveField(6)
  final DateTime? endDate;

  /// List of tasks to complete as part of this plan
  @HiveField(7)
  final List<TreatmentTask> tasks;

  /// Whether this plan is currently active
  @HiveField(8)
  final bool isActive;

  /// Timestamp when this plan was created
  @HiveField(9)
  final DateTime createdAt;

  /// Timestamp when this plan was last modified
  @HiveField(10)
  final DateTime? updatedAt;

  TreatmentPlan({
    required this.id,
    required this.petId,
    required this.name,
    required this.description,
    this.veterinarianName,
    required this.startDate,
    this.endDate,
    required this.tasks,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy of this plan with optional field modifications
  TreatmentPlan copyWith({
    String? id,
    String? petId,
    String? name,
    String? description,
    String? veterinarianName,
    DateTime? startDate,
    DateTime? endDate,
    List<TreatmentTask>? tasks,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TreatmentPlan(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      description: description ?? this.description,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tasks: tasks ?? this.tasks,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'description': description,
      'veterinarianName': veterinarianName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['id'] as String,
      petId: json['petId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      veterinarianName: json['veterinarianName'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      tasks: (json['tasks'] as List<dynamic>)
          .map((taskJson) =>
              TreatmentTask.fromJson(taskJson as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Calculate completion percentage (0-100)
  double get completionPercentage {
    if (tasks.isEmpty) return 0.0;
    final completedCount = tasks.where((task) => task.isCompleted).length;
    return (completedCount / tasks.length) * 100;
  }

  /// Get all incomplete tasks sorted by scheduled date
  List<TreatmentTask> get incompleteTasks {
    return tasks
        .where((task) => !task.isCompleted)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Get all completed tasks sorted by completion date
  List<TreatmentTask> get completedTasks {
    return tasks
        .where((task) => task.isCompleted)
        .toList()
      ..sort((a, b) {
        if (a.completedAt == null || b.completedAt == null) return 0;
        return b.completedAt!.compareTo(a.completedAt!);
      });
  }

  @override
  String toString() {
    return 'TreatmentPlan(id: $id, petId: $petId, name: $name, '
        'startDate: $startDate, endDate: $endDate, tasks: ${tasks.length}, '
        'isActive: $isActive, completion: ${completionPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TreatmentPlan &&
        other.id == id &&
        other.petId == petId &&
        other.name == name &&
        other.description == description &&
        other.veterinarianName == veterinarianName &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        petId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        veterinarianName.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        isActive.hashCode;
  }
}

/// Represents a single task within a treatment plan
///
/// Each task is an actionable item with a scheduled date/time, completion status,
/// and optional notes. Tasks can be of different types: medication, appointment,
/// care (e.g., wound cleaning), or other.
@HiveType(typeId: 28)
class TreatmentTask {
  /// Unique identifier for this task
  @HiveField(0)
  final String id;

  /// Title of the task (e.g., "Administer antibiotic", "Follow-up appointment")
  @HiveField(1)
  final String title;

  /// Detailed description of the task
  @HiveField(2)
  final String? description;

  /// Date when this task is scheduled
  @HiveField(3)
  final DateTime scheduledDate;

  /// Time of day when this task is scheduled (optional)
  @HiveField(4)
  final TimeOfDayModel? scheduledTime;

  /// Whether this task has been completed
  @HiveField(5)
  final bool isCompleted;

  /// Timestamp when this task was completed (null if not completed)
  @HiveField(6)
  final DateTime? completedAt;

  /// Notes about task completion or execution
  @HiveField(7)
  final String? notes;

  /// Type of task: 'medication', 'appointment', 'care', or 'other'
  @HiveField(8)
  final String taskType;

  TreatmentTask({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledDate,
    this.scheduledTime,
    this.isCompleted = false,
    this.completedAt,
    this.notes,
    this.taskType = 'other',
  }) : assert(
          taskType == 'medication' ||
              taskType == 'appointment' ||
              taskType == 'care' ||
              taskType == 'other',
          'taskType must be one of: "medication", "appointment", "care", "other"',
        ),
        assert(
          !isCompleted || completedAt != null,
          'completedAt must be set when isCompleted is true',
        );

  /// Create a copy of this task with optional field modifications
  TreatmentTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledDate,
    TimeOfDayModel? scheduledTime,
    bool? isCompleted,
    DateTime? completedAt,
    String? notes,
    String? taskType,
  }) {
    return TreatmentTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      taskType: taskType ?? this.taskType,
    );
  }

  /// Mark this task as completed with current timestamp
  TreatmentTask markCompleted({String? notes}) {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      notes: notes ?? this.notes,
    );
  }

  /// Mark this task as incomplete
  TreatmentTask markIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime?.toJson(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'taskType': taskType,
    };
  }

  /// Create from JSON map
  factory TreatmentTask.fromJson(Map<String, dynamic> json) {
    return TreatmentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledTime: json['scheduledTime'] != null
          ? TimeOfDayModel.fromJson(json['scheduledTime'] as Map<String, dynamic>)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      taskType: json['taskType'] as String? ?? 'other',
    );
  }

  /// Whether this task is overdue (past scheduled date and not completed)
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return scheduledDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Whether this task is due today
  bool get isDueToday {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    return taskDate == today;
  }

  @override
  String toString() {
    return 'TreatmentTask(id: $id, title: $title, taskType: $taskType, '
        'scheduledDate: $scheduledDate, isCompleted: $isCompleted, '
        'completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TreatmentTask &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.scheduledDate == scheduledDate &&
        other.isCompleted == isCompleted &&
        other.completedAt == completedAt &&
        other.notes == notes &&
        other.taskType == taskType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        scheduledDate.hashCode ^
        isCompleted.hashCode ^
        completedAt.hashCode ^
        notes.hashCode ^
        taskType.hashCode;
  }
}
