
class UserProfile {
  final String id;
  final String displayName;
  final String? photoPath;
  const UserProfile({required this.id, required this.displayName, this.photoPath});
  Map<String, dynamic> toJson() => {'id': id, 'displayName': displayName, 'photoPath': photoPath};
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(id: j['id'], displayName: j['displayName'], photoPath: j['photoPath']);
}
