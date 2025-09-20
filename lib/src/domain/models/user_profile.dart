import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 8)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String? email;
  
  @HiveField(3)
  String? profilePicturePath;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime updatedAt;
  
  @HiveField(6)
  bool hasCompletedOnboarding;

  UserProfile({
    String? id,
    required this.name,
    this.email,
    this.profilePicturePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.hasCompletedOnboarding = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'profilePicturePath': profilePicturePath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'hasCompletedOnboarding': hasCompletedOnboarding,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    profilePicturePath: json['profilePicturePath'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
  );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicturePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasCompletedOnboarding,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}