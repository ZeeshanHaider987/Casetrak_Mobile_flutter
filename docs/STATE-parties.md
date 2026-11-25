# Parties (MatterPayer / RelatedContact / TrustRecipient) — State

Status: not started
Mock: not built
Remote: not built

## DTOs involved (from @10-dto-contract.mdc)
Matter Payer:
  GetMatterPayerDto, CreateMatterPayerRequest, UpdateMatterPayerRequest,
  MatterPayerResponse, MatterPayerListResponse
Matter Related Contact:
  GetMatterRelatedContactDto, CreateMatterRelatedContactRequest,
  UpdateMatterRelatedContactRequest, MatterRelatedContactResponse,
  MatterRelatedContactListResponse
Case Trust Notification Recipient:
  GetCaseTrustNotificationRecipientDto,
  CreateCaseTrustNotificationRecipientRequest,
  UpdateCaseTrustNotificationRecipientRequest,
  CaseTrustNotificationRecipientResponse,
  CaseTrustNotificationRecipientListResponse

## Endpoints (remote — confirm with backend Swagger)
MatterPayer         → /matter-payers?caseId=, POST /matter-payers,
                      PATCH /matter-payers/:id, DELETE /matter-payers/:id
MatterRelatedContact → /matter-related-contacts?caseId=, POST, PATCH, DELETE
CaseTrustNotifRecip  → /case-trust-notification-recipients?caseId=,
                       POST, PATCH, DELETE

## Where these render
Matter detail → Parties tab → 3 sub-tabs (Payer / Related / Trust)

## Fields to show per row
Payer:     invoicePortion, sendCopy, billRecipient, relationshipType,
           isDefault
Related:   relationshipType, isDefaultRecipient, isActive
Trust:     isNotifiedRecipient, isActive

## Rules that apply
- @00-project.mdc (optimistic UI on create/delete, confirmation dialog)
- @10-dto-contract.mdc (exact field names)
- @40-ui.mdc (skeleton list, empty state, destructive confirm)

## Known issues
- (add here)

## Next
- PartiesRepository interface
- MockPartiesRepo seeded with 2 payers, 3 related, 1 trust recipient
- Sub-tab widgets on Matter detail
- Create/Edit sheets per entity