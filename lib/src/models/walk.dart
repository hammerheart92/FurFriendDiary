
class Walk {
  final String id;
  final DateTime start;
  final int durationMinutes;
  final String petId;
  final double? distanceKm;
  const Walk({required this.id, required this.start, required this.durationMinutes, required this.petId, this.distanceKm});
  Map<String, dynamic> toJson() => {'id': id, 'start': start.toIso8601String(), 'durationMinutes': durationMinutes, 'petId': petId, 'distanceKm': distanceKm};
  factory Walk.fromJson(Map<String, dynamic> j) => Walk(id: j['id'], start: DateTime.parse(j['start']), durationMinutes: j['durationMinutes'], petId: j['petId'], distanceKm: (j['distanceKm'] as num?)?.toDouble());
}
