import 'package:dio/dio.dart';

/// Transport or contract failure that is safe to show. Callers never see a raw
/// [DioException] for client-creation failures.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Inline field errors on the Create Client wizard.
class InvalidClientException implements Exception {
  InvalidClientException(this.fieldErrors, {this.message = 'Check the highlighted fields.'});

  final Map<String, String> fieldErrors;
  final String message;

  @override
  String toString() => message;
}

/// A client like this already exists. The wizard shows a link-or-create dialog.
class DuplicateClientException implements Exception {
  DuplicateClientException({
    required this.existingClientId,
    this.message = 'A client like this already exists — link or create anyway?',
  });

  final String existingClientId;
  final String message;

  @override
  String toString() => message;
}

/// Maps Dio failures onto typed exceptions. [InvalidClientException] and
/// [DuplicateClientException] never surface as [DioException].
Exception mapDioException(DioException error) {
  final data = error.response?.data;
  if (data is Map) {
    final json = data.map((key, value) => MapEntry(key.toString(), value));
    final code = json['code']?.toString();
    if (code == 'InvalidClient') {
      return InvalidClientException(
        _fieldErrors(json['errors']),
        message: json['message']?.toString() ?? 'Check the highlighted fields.',
      );
    }
    if (code == 'DuplicateClient') {
      return DuplicateClientException(
        existingClientId: json['existingClientId']?.toString() ?? '',
        message: json['message']?.toString() ??
            'A client like this already exists — link or create anyway?',
      );
    }
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      return ApiException(errors.first.toString(), statusCode: error.response?.statusCode);
    }
    final message = json['message']?.toString();
    if (message != null && message.isNotEmpty) {
      return ApiException(message, statusCode: error.response?.statusCode);
    }
  }
  return ApiException(
    error.message ?? 'Request failed',
    statusCode: error.response?.statusCode,
  );
}

Map<String, String> _fieldErrors(Object? raw) {
  if (raw is! List) return const {};
  final mapped = <String, String>{};
  for (final entry in raw) {
    if (entry is Map) {
      final field = entry['field']?.toString();
      final message = entry['message']?.toString();
      if (field != null && message != null) mapped[field] = message;
    }
  }
  return mapped;
}

Future<T> guardDio<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (error) {
    throw mapDioException(error);
  }
}
