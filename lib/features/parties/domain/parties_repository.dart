import '../data/models/party_dtos.dart';

abstract class PartiesRepository {
  Future<MatterPayerListResponse> listPayers(String caseId);
  Future<MatterPayerResponse> createPayer(CreateMatterPayerRequest request);
  Future<MatterPayerResponse> updatePayer(String id, UpdateMatterPayerRequest request);
  Future<void> deletePayer(String id);

  Future<MatterRelatedContactListResponse> listRelated(String caseId);
  Future<MatterRelatedContactResponse> createRelated(CreateMatterRelatedContactRequest request);
  Future<MatterRelatedContactResponse> updateRelated(String id, UpdateMatterRelatedContactRequest request);
  Future<void> deleteRelated(String id);

  Future<CaseTrustNotificationRecipientListResponse> listTrust(String caseId);
  Future<CaseTrustNotificationRecipientResponse> createTrust(
    CreateCaseTrustNotificationRecipientRequest request,
  );
  Future<CaseTrustNotificationRecipientResponse> updateTrust(
    String id,
    UpdateCaseTrustNotificationRecipientRequest request,
  );
  Future<void> deleteTrust(String id);
}
