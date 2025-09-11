
class Appointment {
  final String id;
  final String petId;
  final DateTime time;
  final String vet;
  final String? notes;
  const Appointment({required this.id, required this.petId, required this.time, required this.vet, this.notes});
  Map<String, dynamic> toJson() => {'id': id, 'petId': petId, 'time': time.toIso8601String(), 'vet': vet, 'notes': notes};
  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(id: j['id'], petId: j['petId'], time: DateTime.parse(j['time']), vet: j['vet'], notes: j['notes']);
}
