class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => message;
}

class PermissionPermanentlyDeniedException implements Exception {
  final String message;
  PermissionPermanentlyDeniedException(this.message);

  @override
  String toString() => message;
}
