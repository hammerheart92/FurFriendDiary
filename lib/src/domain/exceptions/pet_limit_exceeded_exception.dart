/// Exception thrown when a user tries to add more pets than their tier allows.
///
/// This is used to enforce FREE tier limits (1 pet maximum).
class PetLimitExceededException implements Exception {
  final String message;
  final int currentPetCount;
  final int petLimit;

  PetLimitExceededException({
    required this.message,
    required this.currentPetCount,
    required this.petLimit,
  });

  @override
  String toString() => message;

  /// Factory constructor for FREE tier limit
  factory PetLimitExceededException.freeTierLimit({
    required int currentPetCount,
  }) {
    return PetLimitExceededException(
      message:
          'Free tier allows only 1 pet. Upgrade to Premium for unlimited pets.',
      currentPetCount: currentPetCount,
      petLimit: 1,
    );
  }
}
