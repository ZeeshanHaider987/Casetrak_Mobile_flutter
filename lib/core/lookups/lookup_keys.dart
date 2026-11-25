/// Lookup keys enumerated in the contract. The heading says 29; the exhaustive
/// list itself contains these 27 entries. No extra keys are invented.
class LookupKeys {
  const LookupKeys._();

  static const nameTitle = 'nameTitle';
  static const industryType = 'industryType';
  static const addressType = 'addressType';
  static const country = 'country';
  static const pocList = 'pocList';
  static const clientType = 'clientType';
  static const partnerList = 'partnerList';
  static const aquiredPartnerList = 'aquiredPartnerList';
  static const feeEarnerList = 'feeEarnerList';
  static const personAssistList = 'personAssistList';
  static const allUserAssignList = 'allUserAssignList';
  static const practicesArea = 'practicesArea';
  static const companyClients = 'companyClients';
  static const feeType = 'feeType';
  static const expenseType = 'expenseType';
  static const entitiesStatusType = 'entitiesStatusType';
  static const department = 'department';
  static const currency = 'currency';
  static const clientGroup = 'clientGroup';
  static const caseType = 'caseType';
  static const caseStatusType = 'caseStatusType';
  static const billingType = 'billingType';
  static const roundingIncrements = 'roundingIncrements';
  static const userTypes = 'userTypes';
  static const timezones = 'timezones';
  static const chargeTypes = 'chargeTypes';
  static const legalAidStatuses = 'legalAidStatuses';

  static const all = <String>[
    nameTitle,
    industryType,
    addressType,
    country,
    pocList,
    clientType,
    partnerList,
    aquiredPartnerList,
    feeEarnerList,
    personAssistList,
    allUserAssignList,
    practicesArea,
    companyClients,
    feeType,
    expenseType,
    entitiesStatusType,
    department,
    currency,
    clientGroup,
    caseType,
    caseStatusType,
    billingType,
    roundingIncrements,
    userTypes,
    timezones,
    chargeTypes,
    legalAidStatuses,
  ];

  /// Volatile keys. Invalidated when the app returns to the foreground.
  static const shortTtl = <String>[
    companyClients,
    allUserAssignList,
    feeEarnerList,
    partnerList,
  ];

  static const longTtl = <String>[
    country,
    currency,
    timezones,
    department,
    entitiesStatusType,
  ];
}
