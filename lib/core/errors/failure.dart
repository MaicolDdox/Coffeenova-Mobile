class Failure implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const Failure({
    required this.message,
    this.errors,
    this.statusCode,
  });

  @override
  String toString() => 'Failure($message)';
}
