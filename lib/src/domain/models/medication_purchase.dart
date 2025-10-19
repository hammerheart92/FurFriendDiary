import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'medication_purchase.g.dart';

@HiveType(typeId: 18)
class MedicationPurchase extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String medicationId;

  @HiveField(2)
  String petId;

  @HiveField(3)
  int quantity; // units purchased

  @HiveField(4)
  double cost;

  @HiveField(5)
  DateTime purchaseDate;

  @HiveField(6)
  String? pharmacy;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  MedicationPurchase({
    String? id,
    required this.medicationId,
    required this.petId,
    required this.quantity,
    required this.cost,
    required this.purchaseDate,
    this.pharmacy,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'petId': petId,
        'quantity': quantity,
        'cost': cost,
        'purchaseDate': purchaseDate.toIso8601String(),
        'pharmacy': pharmacy,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MedicationPurchase.fromJson(Map<String, dynamic> json) =>
      MedicationPurchase(
        id: json['id'],
        medicationId: json['medicationId'],
        petId: json['petId'],
        quantity: json['quantity'],
        cost: json['cost'],
        purchaseDate: DateTime.parse(json['purchaseDate']),
        pharmacy: json['pharmacy'],
        notes: json['notes'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  MedicationPurchase copyWith({
    String? id,
    String? medicationId,
    String? petId,
    int? quantity,
    double? cost,
    DateTime? purchaseDate,
    String? pharmacy,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationPurchase(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      petId: petId ?? this.petId,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pharmacy: pharmacy ?? this.pharmacy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
