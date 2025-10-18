import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'pet_photo.g.dart';

@HiveType(typeId: 16)
class PetPhoto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  String thumbnailPath;

  @HiveField(4)
  String? caption;

  @HiveField(5)
  DateTime dateTaken;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  int fileSize; // in bytes

  @HiveField(8)
  String? medicationId;

  @HiveField(9)
  String? appointmentId;

  PetPhoto({
    String? id,
    required this.petId,
    required this.filePath,
    required this.thumbnailPath,
    this.caption,
    required this.dateTaken,
    DateTime? createdAt,
    required this.fileSize,
    this.medicationId,
    this.appointmentId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'filePath': filePath,
        'thumbnailPath': thumbnailPath,
        'caption': caption,
        'dateTaken': dateTaken.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'fileSize': fileSize,
        'medicationId': medicationId,
        'appointmentId': appointmentId,
      };

  factory PetPhoto.fromJson(Map<String, dynamic> json) => PetPhoto(
        id: json['id'],
        petId: json['petId'],
        filePath: json['filePath'],
        thumbnailPath: json['thumbnailPath'],
        caption: json['caption'],
        dateTaken: DateTime.parse(json['dateTaken']),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        fileSize: json['fileSize'],
        medicationId: json['medicationId'],
        appointmentId: json['appointmentId'],
      );

  PetPhoto copyWith({
    String? id,
    String? petId,
    String? filePath,
    String? thumbnailPath,
    String? caption,
    DateTime? dateTaken,
    DateTime? createdAt,
    int? fileSize,
    String? medicationId,
    String? appointmentId,
  }) {
    return PetPhoto(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      caption: caption ?? this.caption,
      dateTaken: dateTaken ?? this.dateTaken,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      medicationId: medicationId ?? this.medicationId,
      appointmentId: appointmentId ?? this.appointmentId,
    );
  }
}
