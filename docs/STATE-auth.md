# Auth — State

Status: not started
Mock: not built
Remote: not built

## DTOs involved
- (none from contract file — auth returns token + tenantId + LoginUser)

## Endpoints (remote — confirm exact path with backend Swagger)
POST /auth/login          → { token, tenantId, user }
POST /auth/forgot-password
GET  /auth/me             → LoginUser

## Rules that apply
- @00-project.mdc (USE_MOCK flag, JWT in flutter_secure_storage)
- @10-dto-contract.mdc (ApiResponse envelope, typed errors)

## Role visibility (per 00-project.mdc)
Admin, Partner       → all nav items
FeeEarner            → Dashboard, Matters, Clients, Time
RelationshipManager  → Dashboard, Matters (linked only), Clients
PersonAssisting      → Dashboard, Matters (linked only)

## Known issues
- (add here as you find them)

## Next
- Build AuthRepository interface + MockAuthRepo
- Build LoginScreen + ForgotPasswordScreen
- Persist token + tenantId, add 401 → logout interceptor hook