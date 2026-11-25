import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../domain/parties_repository.dart';
import 'models/party_dtos.dart';

class RemotePartiesRepo implements PartiesRepository {
  RemotePartiesRepo(this._dio);

  final Dio _dio;

  @override
  Future<MatterPayerListResponse> listPayers(String caseId) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/matter-payers',
        queryParameters: {'caseId': caseId},
      );
      return MatterPayerListResponse.fromJson(_payload(response.data));
    });
  }

  @override
  Future<MatterPayerResponse> createPayer(CreateMatterPayerRequest request) {
    return guardDio(() async {
      final response = await _dio.post<Map<String, dynamic>>('/matter-payers', data: request.toJson());
      return MatterPayerResponse.fromJson(_payload(response.data));
    });
  }

  @override
  Future<MatterPayerResponse> updatePayer(String id, UpdateMatterPayerRequest request) {
    return guardDio(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/matter-payers/$id',
        data: request.toJson(),
      );
      return MatterPayerResponse.fromJson(_payload(response.data));
    });
  }

  @override
  Future<void> deletePayer(String id) {
    return guardDio(() async {
      await _dio.delete<void>('/matter-payers/$id');
    });
  }

  @override
  Future<MatterRelatedContactListResponse> listRelated(String caseId) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/matter-related-contacts',
        queryParameters: {'caseId': caseId},
      );
      final items = _list(response.data)
          .map(GetMatterRelatedContactDto.fromJson)
          .toList();
      return MatterRelatedContactListResponse(items: items);
    });
  }

  @override
  Future<MatterRelatedContactResponse> createRelated(CreateMatterRelatedContactRequest request) {
    return guardDio(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/matter-related-contacts',
        data: request.toJson(),
      );
      return MatterRelatedContactResponse.fromJson(_payload(response.data));
    });
  }

  @override
  Future<MatterRelatedContactResponse> updateRelated(
    String id,
    UpdateMatterRelatedContactRequest request,
  ) {
    return guardDio(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/matter-related-contacts/$id',
        data: request.toJson(),
      );
      return MatterRelatedContactResponse.fromJson(_payload(response.data));
    });
  }

  @override
  Future<void> deleteRelated(String id) {
    return guardDio(() async {
      await _dio.delete<void>('/matter-related-contacts/$id');
    });
  }

  @override
  Future<CaseTrustNotificationRecipientListResponse> listTrust(String caseId) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/case-trust-notification-recipients',
        queryParameters: {'caseId': caseId},
      );
      final items = _list(response.data).map(GetCaseTrustNotificationRecipientDto.fromJson).toList();
      return CaseTrustNotificationRecipientListResponse(items: items);
    });
  }

  @override
  Future<CaseTrustNotificationRecipientResponse> createTrust(
    CreateCaseTrustNotificationRecipientRequest request,
  ) {
    return guardDio(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/case-trust-notification-recipients',
        data: request.toJson(),
      );
      return CaseTrustNotificationRecipientResponse.fromJson(_payload(response.data));
    });
  }

  @override
  Future<CaseTrustNotificationRecipientResponse> updateTrust(
    String id,
    UpdateCaseTrustNotificationRecipientRequest request,
  ) {
    return guardDio(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/case-trust-notification-recipients/$id',
        data: request.toJson(),
      );
      return CaseTrustNotificationRecipientResponse.fromJson(_payload(response.data));
    });
  }

  @override
  Future<void> deleteTrust(String id) {
    return guardDio(() async {
      await _dio.delete<void>('/case-trust-notification-recipients/$id');
    });
  }

  Map<String, dynamic> _payload(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
    return body ?? const {};
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic>? body) {
    final payload = _payload(body);
    final raw = payload['items'] ?? body?['items'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) => item.map((k, v) => MapEntry(k.toString(), v))).toList();
  }
}
