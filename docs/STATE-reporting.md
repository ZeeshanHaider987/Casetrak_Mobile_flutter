# Reporting — State

Status: not started
Mock: not built
Remote: not built

## DTOs involved (from @10-dto-contract.mdc)
UnpaidInvoiceAgingDto, UnpaidInvoiceAgingRequest, UnpaidInvoiceAgingResponse,
MonthlyBillingDto, MonthlyBillingRequest, MonthlyBillingResponse,
ReportingOverviewResponse, AgingBucketSummary,
AgingReportSummaryResponse, BillingKpiResponse, InvoiceAgingDetailDto

## Endpoints (remote — confirm with backend Swagger)
GET  /reporting/overview
POST /reporting/unpaid-invoice-aging
POST /reporting/aging-summary
GET  /reporting/billing-kpis
POST /reporting/monthly-billing
GET  /reporting/health-check      (per-endpoint OK/Fail + latency)

## Enums (verbatim from @10-dto-contract.mdc)
healthStatus: Excellent | Good | Fair | Poor | Critical
riskLevel:    Low | Medium | High | Critical
agingBuckets: 0-29 | 30-59 | 60-89 | 90+

## Multi-currency rules
- forex_rate table is seeded on the backend.
- Never sum across currencies without conversion.
- Show a "converted" badge when forex_rate was applied.
- Filter sheet always includes currency (from LookupManager.currency).

## Filters (applied to every endpoint)
practiceAreaId, feeEarnerId, currencyCode, dateFrom, dateTo

## Charts (per @30-reporting.mdc)
Aging Summary      → horizontal stacked bar (fl_chart)
Monthly Billing    → grouped bar by month × practiceArea
Invoices by Bucket → bar + table toggle
KPIs               → grid of cards, color by riskLevel

## Role access
Admin, Partner → full access
FeeEarner      → hidden unless backend permission flag enables it
Others         → hidden

## Known issues
- (add here)

## Next
- ReportingRepository interface + MockReportingRepo with realistic buckets
- Overview + Aging Summary screens first
- Billing KPIs + Monthly Billing charts
- Reporting Health Check screen last