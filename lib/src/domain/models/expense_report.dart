import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense_report.g.dart';

const _uuid = Uuid();

@HiveType(typeId: 21)
class ExpenseReport extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  DateTime month; // First day of month

  @HiveField(3)
  double totalExpenses;

  @HiveField(4)
  Map<String, double> categoryBreakdown; // medications, appointments, etc.

  @HiveField(5)
  double averagePerWeek;

  @HiveField(6)
  String mostExpensiveCategory;

  ExpenseReport({
    String? id,
    required this.petId,
    required this.month,
    required this.totalExpenses,
    required this.categoryBreakdown,
    required this.averagePerWeek,
    required this.mostExpensiveCategory,
  }) : id = id ?? _uuid.v4();

  ExpenseReport copyWith({
    String? id,
    String? petId,
    DateTime? month,
    double? totalExpenses,
    Map<String, double>? categoryBreakdown,
    double? averagePerWeek,
    String? mostExpensiveCategory,
  }) {
    return ExpenseReport(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      month: month ?? this.month,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      averagePerWeek: averagePerWeek ?? this.averagePerWeek,
      mostExpensiveCategory:
          mostExpensiveCategory ?? this.mostExpensiveCategory,
    );
  }
}
