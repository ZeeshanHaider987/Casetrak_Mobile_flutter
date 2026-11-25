import 'lookup_item.dart';
import 'lookup_keys.dart';
import 'lookup_repository.dart';

class MockLookupRepo implements LookupRepository {
  MockLookupRepo({Map<String, List<LookupItem>>? seed}) : _seed = seed ?? buildLookupSeed();

  final Map<String, List<LookupItem>> _seed;

  @override
  Future<List<LookupItem>> fetchKey(String key) async {
    final items = _seed[key];
    if (items == null) {
      throw StateError('Unknown lookup key: $key');
    }
    return items;
  }

  @override
  Future<Map<String, List<LookupItem>>> fetchAll() async => _seed;
}

Map<String, List<LookupItem>> buildLookupSeed() {
  List<LookupItem> pairs(String key, List<String> labels) {
    return [
      for (var i = 0; i < labels.length; i++)
        LookupItem(
          id: '$key-${_slug(labels[i])}',
          label: labels[i],
          code: labels[i],
        ),
    ];
  }

  return {
    LookupKeys.nameTitle: pairs(LookupKeys.nameTitle, const ['Mr', 'Mrs', 'Ms', 'Dr', 'Mx']),
    LookupKeys.industryType: pairs(
      LookupKeys.industryType,
      const ['Legal', 'Financial Services', 'Real Estate', 'Technology', 'Healthcare'],
    ),
    LookupKeys.addressType: pairs(
      LookupKeys.addressType,
      const ['Registered', 'Billing', 'Correspondence', 'Residential'],
    ),
    LookupKeys.country: const [
      LookupItem(id: 'country-gb', label: 'United Kingdom', code: 'GB'),
      LookupItem(id: 'country-us', label: 'United States', code: 'US'),
      LookupItem(id: 'country-ae', label: 'United Arab Emirates', code: 'AE'),
      LookupItem(id: 'country-ie', label: 'Ireland', code: 'IE'),
      LookupItem(id: 'country-sg', label: 'Singapore', code: 'SG'),
    ],
    LookupKeys.pocList: const [
      LookupItem(id: 'poc-amelia', label: 'Amelia Clarke'),
      LookupItem(id: 'poc-david', label: 'David Chen'),
      LookupItem(id: 'poc-sofia', label: 'Sofia Martins'),
      LookupItem(id: 'poc-owen', label: 'Owen Blake'),
    ],
    LookupKeys.clientType: const [
      LookupItem(id: 'clientType-individual', label: 'Individual', code: 'Individual'),
      LookupItem(id: 'clientType-company', label: 'Company', code: 'Company'),
      LookupItem(id: 'clientType-trustee', label: 'Trustee', code: 'Trustee'),
    ],
    LookupKeys.partnerList: const [
      LookupItem(id: 'u-partner', label: 'Helen Croft'),
      LookupItem(id: 'partner-james', label: 'James Okonkwo'),
    ],
    LookupKeys.aquiredPartnerList: const [
      LookupItem(id: 'u-partner', label: 'Helen Croft'),
      LookupItem(id: 'partner-james', label: 'James Okonkwo'),
      LookupItem(id: 'partner-lila', label: 'Lila Berg'),
    ],
    LookupKeys.feeEarnerList: const [
      LookupItem(id: 'u-fee', label: 'Noah Bennett'),
      LookupItem(id: 'fee-sara', label: 'Sara Iqbal'),
      LookupItem(id: 'fee-tom', label: 'Tom Ellis'),
    ],
    LookupKeys.personAssistList: const [
      LookupItem(id: 'u-assist', label: 'Priya Nair'),
      LookupItem(id: 'assist-owen', label: 'Owen Blake'),
    ],
    LookupKeys.allUserAssignList: const [
      LookupItem(id: 'u-admin', label: 'Admin User'),
      LookupItem(id: 'u-partner', label: 'Helen Croft'),
      LookupItem(id: 'u-fee', label: 'Noah Bennett'),
      LookupItem(id: 'u-rm', label: 'David Chen'),
      LookupItem(id: 'u-assist', label: 'Priya Nair'),
    ],
    LookupKeys.practicesArea: const [
      LookupItem(id: 'practicesArea-corporate', label: 'Corporate'),
      LookupItem(id: 'practicesArea-litigation', label: 'Litigation'),
      LookupItem(id: 'practicesArea-employment', label: 'Employment'),
      LookupItem(id: 'practicesArea-real-estate', label: 'Real Estate'),
      LookupItem(id: 'practicesArea-private-client', label: 'Private Client'),
    ],
    LookupKeys.companyClients: const [
      LookupItem(id: 'c-003', label: 'Northwind Holdings'),
      LookupItem(id: 'c-004', label: 'Harbor & Co'),
    ],
    LookupKeys.feeType: pairs(LookupKeys.feeType, const ['Hourly', 'Fixed', 'Blended']),
    LookupKeys.expenseType: pairs(
      LookupKeys.expenseType,
      const ['Travel', 'Court Fee', 'Search', 'Postage'],
    ),
    LookupKeys.entitiesStatusType: pairs(
      LookupKeys.entitiesStatusType,
      const ['Active', 'Inactive', 'Archived'],
    ),
    LookupKeys.department: pairs(
      LookupKeys.department,
      const ['Corporate', 'Dispute Resolution', 'Private Client', 'Finance'],
    ),
    LookupKeys.currency: const [
      LookupItem(id: 'currency-gbp', label: 'Pound Sterling', code: 'GBP'),
      LookupItem(id: 'currency-usd', label: 'US Dollar', code: 'USD'),
      LookupItem(id: 'currency-eur', label: 'Euro', code: 'EUR'),
      LookupItem(id: 'currency-aed', label: 'UAE Dirham', code: 'AED'),
    ],
    LookupKeys.clientGroup: pairs(LookupKeys.clientGroup, const ['Key', 'Standard', 'Prospect']),
    LookupKeys.caseType: pairs(
      LookupKeys.caseType,
      const ['Advisory', 'Transaction', 'Dispute', 'Compliance'],
    ),
    LookupKeys.caseStatusType: const [
      LookupItem(id: 'caseStatusType-open', label: 'Open'),
      LookupItem(id: 'caseStatusType-pending', label: 'Pending'),
      LookupItem(id: 'caseStatusType-closed', label: 'Closed'),
      LookupItem(id: 'caseStatusType-on-hold', label: 'On Hold'),
    ],
    LookupKeys.billingType: pairs(
      LookupKeys.billingType,
      const ['Hourly', 'Fixed Fee', 'Legal Aid', 'Contingent'],
    ),
    LookupKeys.roundingIncrements: pairs(
      LookupKeys.roundingIncrements,
      const ['6 minutes', '15 minutes', '30 minutes'],
    ),
    LookupKeys.userTypes: pairs(
      LookupKeys.userTypes,
      const ['Admin', 'Partner', 'FeeEarner', 'RelationshipManager', 'PersonAssisting'],
    ),
    LookupKeys.timezones: const [
      LookupItem(id: 'timezones-london', label: 'Europe/London', code: 'Europe/London'),
      LookupItem(id: 'timezones-dublin', label: 'Europe/Dublin', code: 'Europe/Dublin'),
      LookupItem(id: 'timezones-new-york', label: 'America/New_York', code: 'America/New_York'),
      LookupItem(id: 'timezones-dubai', label: 'Asia/Dubai', code: 'Asia/Dubai'),
    ],
    LookupKeys.chargeTypes: pairs(LookupKeys.chargeTypes, const ['Time', 'Expense', 'Disbursement']),
    LookupKeys.legalAidStatuses: pairs(
      LookupKeys.legalAidStatuses,
      const ['Granted', 'Pending', 'Refused', 'Not Applicable'],
    ),
  };
}

String _slug(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
