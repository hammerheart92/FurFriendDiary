class Feeding {
  final String id;
  final DateTime time;
  final String petId;
  final String food;
  final double amountGrams;
  final String? note;
  const Feeding(
      {required this.id,
      required this.time,
      required this.petId,
      required this.food,
      required this.amountGrams,
      this.note});
  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time.toIso8601String(),
        'petId': petId,
        'food': food,
        'amountGrams': amountGrams,
        'note': note
      };
  factory Feeding.fromJson(Map<String, dynamic> j) => Feeding(
      id: j['id'],
      time: DateTime.parse(j['time']),
      petId: j['petId'],
      food: j['food'],
      amountGrams: (j['amountGrams'] as num).toDouble(),
      note: j['note']);
}
