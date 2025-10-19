import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feeding_form_state_provider.g.dart';

class FeedingFormState {
  final String foodType;
  final double? amount;
  final TimeOfDay? time;
  final DateTime? date;
  final String? notes;

  const FeedingFormState({
    this.foodType = '',
    this.amount,
    this.time,
    this.date,
    this.notes,
  });

  FeedingFormState copyWith({
    String? foodType,
    double? amount,
    TimeOfDay? time,
    DateTime? date,
    String? notes,
  }) {
    return FeedingFormState(
      foodType: foodType ?? this.foodType,
      amount: amount ?? this.amount,
      time: time ?? this.time,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  bool get isEmpty =>
      foodType.isEmpty &&
      amount == null &&
      time == null &&
      date == null &&
      (notes?.isEmpty ?? true);

  bool get isValid => foodType.isNotEmpty;
}

@riverpod
class FeedingFormStateNotifier extends _$FeedingFormStateNotifier {
  @override
  FeedingFormState build() {
    return const FeedingFormState();
  }

  void updateFoodType(String foodType) {
    state = state.copyWith(foodType: foodType);
  }

  void updateAmount(double? amount) {
    state = state.copyWith(amount: amount);
  }

  void updateTime(TimeOfDay? time) {
    state = state.copyWith(time: time);
  }

  void updateDate(DateTime? date) {
    state = state.copyWith(date: date);
  }

  void updateNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void clearForm() {
    state = const FeedingFormState();
  }

  void setInitialState({
    String? foodType,
    double? amount,
    TimeOfDay? time,
    DateTime? date,
    String? notes,
  }) {
    state = FeedingFormState(
      foodType: foodType ?? '',
      amount: amount,
      time: time,
      date: date,
      notes: notes,
    );
  }
}
