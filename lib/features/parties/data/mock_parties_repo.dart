import '../domain/parties_repository.dart';
import 'models/party_dtos.dart';

class MockPartiesRepo implements PartiesRepository {
  MockPartiesRepo() {
    _payers.addAll(const [
      GetMatterPayerDto(
        id: 'payer-001',
        caseId: 'm-001',
        invoicePortion: 70,
        sendCopy: true,
        billRecipient: 'Northwind Holdings',
        relationshipType: 'Client',
        isDefault: true,
      ),
      GetMatterPayerDto(
        id: 'payer-002',
        caseId: 'm-001',
        invoicePortion: 30,
        sendCopy: false,
        billRecipient: 'Harbor & Co',
        relationshipType: 'Co-client',
        isDefault: false,
      ),
    ]);
    _related.addAll(const [
      GetMatterRelatedContactDto(
        id: 'rel-001',
        caseId: 'm-001',
        relationshipType: 'Director',
        isDefaultRecipient: true,
        isActive: true,
      ),
      GetMatterRelatedContactDto(
        id: 'rel-002',
        caseId: 'm-001',
        relationshipType: 'Counsel',
        isDefaultRecipient: false,
        isActive: true,
      ),
      GetMatterRelatedContactDto(
        id: 'rel-003',
        caseId: 'm-001',
        relationshipType: 'Referrer',
        isDefaultRecipient: false,
        isActive: false,
      ),
    ]);
    _trust.add(
      const GetCaseTrustNotificationRecipientDto(
        id: 'trust-001',
        caseId: 'm-001',
        isNotifiedRecipient: true,
        isActive: true,
      ),
    );
  }

  final List<GetMatterPayerDto> _payers = [];
  final List<GetMatterRelatedContactDto> _related = [];
  final List<GetCaseTrustNotificationRecipientDto> _trust = [];
  var _seq = 100;

  @override
  Future<MatterPayerListResponse> listPayers(String caseId) async {
    return MatterPayerListResponse(items: _payers.where((item) => item.caseId == caseId).toList());
  }

  @override
  Future<MatterPayerResponse> createPayer(CreateMatterPayerRequest request) async {
    if (request.isDefault) _clearDefaultPayer(request.caseId);
    final created = GetMatterPayerDto(
      id: 'payer-${_seq++}',
      caseId: request.caseId,
      invoicePortion: request.invoicePortion,
      sendCopy: request.sendCopy,
      billRecipient: request.billRecipient,
      relationshipType: request.relationshipType,
      isDefault: request.isDefault,
    );
    _payers.add(created);
    return MatterPayerResponse(payer: created);
  }

  @override
  Future<MatterPayerResponse> updatePayer(String id, UpdateMatterPayerRequest request) async {
    final index = _payers.indexWhere((item) => item.id == id);
    final current = _payers[index];
    if (request.isDefault) _clearDefaultPayer(current.caseId);
    final updated = current.copyWith(
      invoicePortion: request.invoicePortion,
      sendCopy: request.sendCopy,
      billRecipient: request.billRecipient,
      relationshipType: request.relationshipType,
      isDefault: request.isDefault,
    );
    _payers[index] = updated;
    return MatterPayerResponse(payer: updated);
  }

  @override
  Future<void> deletePayer(String id) async => _payers.removeWhere((item) => item.id == id);

  @override
  Future<MatterRelatedContactListResponse> listRelated(String caseId) async {
    return MatterRelatedContactListResponse(
      items: _related.where((item) => item.caseId == caseId).toList(),
    );
  }

  @override
  Future<MatterRelatedContactResponse> createRelated(CreateMatterRelatedContactRequest request) async {
    final created = GetMatterRelatedContactDto(
      id: 'rel-${_seq++}',
      caseId: request.caseId,
      relationshipType: request.relationshipType,
      isDefaultRecipient: request.isDefaultRecipient,
      isActive: request.isActive,
    );
    _related.add(created);
    return MatterRelatedContactResponse(contact: created);
  }

  @override
  Future<MatterRelatedContactResponse> updateRelated(
    String id,
    UpdateMatterRelatedContactRequest request,
  ) async {
    final index = _related.indexWhere((item) => item.id == id);
    final current = _related[index];
    final updated = GetMatterRelatedContactDto(
      id: current.id,
      caseId: current.caseId,
      relationshipType: request.relationshipType,
      isDefaultRecipient: request.isDefaultRecipient,
      isActive: request.isActive,
    );
    _related[index] = updated;
    return MatterRelatedContactResponse(contact: updated);
  }

  @override
  Future<void> deleteRelated(String id) async => _related.removeWhere((item) => item.id == id);

  @override
  Future<CaseTrustNotificationRecipientListResponse> listTrust(String caseId) async {
    return CaseTrustNotificationRecipientListResponse(
      items: _trust.where((item) => item.caseId == caseId).toList(),
    );
  }

  @override
  Future<CaseTrustNotificationRecipientResponse> createTrust(
    CreateCaseTrustNotificationRecipientRequest request,
  ) async {
    final created = GetCaseTrustNotificationRecipientDto(
      id: 'trust-${_seq++}',
      caseId: request.caseId,
      isNotifiedRecipient: request.isNotifiedRecipient,
      isActive: request.isActive,
    );
    _trust.add(created);
    return CaseTrustNotificationRecipientResponse(recipient: created);
  }

  @override
  Future<CaseTrustNotificationRecipientResponse> updateTrust(
    String id,
    UpdateCaseTrustNotificationRecipientRequest request,
  ) async {
    final index = _trust.indexWhere((item) => item.id == id);
    final current = _trust[index];
    final updated = GetCaseTrustNotificationRecipientDto(
      id: current.id,
      caseId: current.caseId,
      isNotifiedRecipient: request.isNotifiedRecipient,
      isActive: request.isActive,
    );
    _trust[index] = updated;
    return CaseTrustNotificationRecipientResponse(recipient: updated);
  }

  @override
  Future<void> deleteTrust(String id) async => _trust.removeWhere((item) => item.id == id);

  void _clearDefaultPayer(String caseId) {
    for (var i = 0; i < _payers.length; i++) {
      final item = _payers[i];
      if (item.caseId == caseId && item.isDefault) {
        _payers[i] = item.copyWith(isDefault: false);
      }
    }
  }
}
