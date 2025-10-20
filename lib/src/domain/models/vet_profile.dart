import 'package:hive/hive.dart';

part 'vet_profile.g.dart';

@HiveType(typeId: 19)
class VetProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String clinicName;

  @HiveField(3)
  String? specialty;

  @HiveField(4)
  String? phoneNumber;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? address;

  @HiveField(7)
  String? website;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  bool isPreferred;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime? lastVisitDate;

  VetProfile({
    required this.id,
    required this.name,
    required this.clinicName,
    this.specialty,
    this.phoneNumber,
    this.email,
    this.address,
    this.website,
    this.notes,
    this.isPreferred = false,
    required this.createdAt,
    this.lastVisitDate,
  });

  VetProfile copyWith({
    String? id,
    String? name,
    String? clinicName,
    String? specialty,
    String? phoneNumber,
    String? email,
    String? address,
    String? website,
    String? notes,
    bool? isPreferred,
    DateTime? createdAt,
    DateTime? lastVisitDate,
  }) {
    return VetProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      clinicName: clinicName ?? this.clinicName,
      specialty: specialty ?? this.specialty,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      isPreferred: isPreferred ?? this.isPreferred,
      createdAt: createdAt ?? this.createdAt,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clinicName': clinicName,
      'specialty': specialty,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'website': website,
      'notes': notes,
      'isPreferred': isPreferred,
      'createdAt': createdAt.toIso8601String(),
      'lastVisitDate': lastVisitDate?.toIso8601String(),
    };
  }

  factory VetProfile.fromJson(Map<String, dynamic> json) {
    return VetProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      clinicName: json['clinicName'] as String,
      specialty: json['specialty'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      isPreferred: json['isPreferred'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastVisitDate: json['lastVisitDate'] != null
          ? DateTime.parse(json['lastVisitDate'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'VetProfile(id: $id, name: $name, clinicName: $clinicName, specialty: $specialty, isPreferred: $isPreferred)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VetProfile &&
        other.id == id &&
        other.name == name &&
        other.clinicName == clinicName &&
        other.specialty == specialty &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.address == address &&
        other.website == website &&
        other.notes == notes &&
        other.isPreferred == isPreferred &&
        other.createdAt == createdAt &&
        other.lastVisitDate == lastVisitDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      clinicName,
      specialty,
      phoneNumber,
      email,
      address,
      website,
      notes,
      isPreferred,
      createdAt,
      lastVisitDate,
    );
  }
}
