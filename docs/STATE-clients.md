# Clients — State

Status: not started
Mock: not built
Remote: not built

## DTOs involved (from @10-dto-contract.mdc)
ClientDto
CreateIndividualClientRequest
CreateCompanyClientRequest
CreateTrusteeClientRequest
InvalidClientException
DuplicateClientException

## Endpoints (remote — confirm with backend Swagger)
GET   /clients                    → paginated list (search, type filter)
GET   /clients/:id                → ClientDto
POST  /clients/individual         → CreateIndividualClientRequest
POST  /clients/company            → CreateCompanyClientRequest
POST  /clients/trustee            → CreateTrusteeClientRequest
PATCH /clients/:id

## Client types (exactly 3)
Individual | Company | Trustee
The Create Client wizard branches on this — each branch builds a
different request DTO. The handler determineClientType() mirrors the
web app's `determineClientType` helper.

## Error handling (critical — from @00-project.mdc)
InvalidClientException  → inline field errors in the wizard
DuplicateClientException → warning dialog:
  "A client like this already exists — link or create anyway?"
Neither may surface as a raw DioException.

## Screens
ClientsListScreen     (search + type chips + badges)
ClientDetailScreen    (contact info, custom fields, linked matters)
CreateClientWizard    (3 branches, one per client type)
ClientCreationSuccess (post-create handoff → optional "Create matter now?")

## Lookups used (from LookupManager)
clientType, nameTitle, industryType, addressType, country, pocList,
companyClients, clientGroup, department

## Rules that apply
- @00-project.mdc (typed exceptions, no raw DioException)
- @10-dto-contract.mdc (exact DTO per client type)
- @40-ui.mdc (wizard UX, inline validation, success → next-step sheet)

## Known issues
- (add here)

## Next
- ClientRepository interface
- MockClientRepo with: 2 individuals, 2 companies, 1 trustee
- Also seed one duplicate-trigger client so the warning dialog is testable
- ClientsList → ClientDetail → CreateClientWizard (3 branches) in that order