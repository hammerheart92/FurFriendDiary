
class Medication {
  final String id;
  final String petId;
  final String name;
  final String dosage;
  final DateTime scheduleTime;
  const Medication({required this.id, required this.petId, required this.name, required this.dosage, required this.scheduleTime});
  Map<String, dynamic> toJson() => {'id': id, 'petId': petId, 'name': name, 'dosage': dosage, 'scheduleTime': scheduleTime.toIso8601String()};
  factory Medication.fromJson(Map<String, dynamic> j) => Medication(id: j['id'], petId: j['petId'], name: j['name'], dosage: j['dosage'], scheduleTime: DateTime.parse(j['scheduleTime']));
}
