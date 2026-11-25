# LookupManager — State

Status: not started
Mock: not built
Remote: not built

## The 29 keys (exhaustive — per @20-lookups.mdc)
nameTitle, industryType, addressType, country, pocList, clientType,
partnerList, aquiredPartnerList, feeEarnerList, personAssistList,
allUserAssignList, practicesArea, companyClients, feeType, expenseType,
entitiesStatusType, department, currency, clientGroup, caseType,
caseStatusType, billingType, roundingIncrements, userTypes, timezones,
chargeTypes, legalAidStatuses

## Endpoint (remote — confirm with backend Swagger)
GET /lookups                 → all keys in one payload (batch)
GET /lookups/{key}           → single key (fallback)
POST /lookups/refresh        → optional cache-bust signal

## TTL tiers (per @20-lookups.mdc)
Short (volatile — auto-invalidate on resume):
  companyClients, allUserAssignList, feeEarnerList, partnerList
Long (stable — weekly):
  country, currency, timezones, department, entitiesStatusType
Medium (default):
  everything else

## Public API of LookupManager
- get(key)            → List<LookupItem> (from cache or fetch)
- getAsync(key)       → Future<List<LookupItem>>
- forceRefresh(key)
- invalidate(key) / invalidateAll()
- cacheTimestamps    → Map<String, DateTime>
- loadingState(key)  → bool
- errorState(key)    → Object?
- batchFetchAll()    → Future<void>  (Future.wait over all keys)

## Debug screen
Settings → Lookup Debug:
  key | cached? | timestamp | count | TTL remaining | [Force refresh]

## Rules that apply
- @20-lookups.mdc (all of it)
- @00-project.mdc (dropdowns never hardcoded)

## Known issues
- (add here)

## Next
- LookupRepository interface + MockLookupRepo (seeded with 3-5 items/key)
- Riverpod LookupManager provider
- LookupDebugScreen in Settings
- Wire every dropdown in the app to LookupManager — audit for hardcoded lists