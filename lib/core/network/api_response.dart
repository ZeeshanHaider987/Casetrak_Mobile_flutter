/// Envelope from the CaseTrak API: `ApiResponse<T>` (`success`, `data`, `errors[]`).
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final T? data;
  final List<String> errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) parse,
  ) {
    return ApiResponse(
      success: json['success'] == true,
      data: json['data'] == null ? null : parse(json['data']),
      errors: _readErrors(json['errors']),
    );
  }

  static List<String> _readErrors(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((entry) => entry.toString()).toList();
  }
}
