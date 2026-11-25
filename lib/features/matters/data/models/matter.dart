class Matter {
  const Matter({
    required this.id,
    required this.matterNumber,
    required this.matterName,
    required this.practicesArea,
    required this.caseStatusType,
    required this.caseType,
    required this.billingType,
    required this.currencyCode,
    required this.clientId,
    required this.feeEarnerId,
    required this.partnerId,
    required this.personAssistId,
    required this.relationshipManagerId,
    required this.openedOn,
    required this.description,
  });

  final String id;
  final String matterNumber;
  final String matterName;

  /// Lookup id from `practicesArea`.
  final String practicesArea;

  /// Lookup id from `caseStatusType`.
  final String caseStatusType;
  final String caseType;
  final String billingType;
  final String currencyCode;
  final String clientId;
  final String feeEarnerId;
  final String partnerId;
  final String personAssistId;
  final String relationshipManagerId;
  final DateTime openedOn;
  final String description;

  Map<String, dynamic> toJson() => {
        'id': id,
        'matterNumber': matterNumber,
        'matterName': matterName,
        'practicesArea': practicesArea,
        'caseStatusType': caseStatusType,
        'caseType': caseType,
        'billingType': billingType,
        'currencyCode': currencyCode,
        'clientId': clientId,
        'feeEarnerId': feeEarnerId,
        'partnerId': partnerId,
        'personAssistId': personAssistId,
        'relationshipManagerId': relationshipManagerId,
        'openedOn': openedOn.toIso8601String(),
        'description': description,
      };

  factory Matter.fromJson(Map<String, dynamic> json) {
    return Matter(
      id: json['id'].toString(),
      matterNumber: json['matterNumber']?.toString() ?? '',
      matterName: json['matterName']?.toString() ?? '',
      practicesArea: json['practicesArea']?.toString() ?? '',
      caseStatusType: json['caseStatusType']?.toString() ?? '',
      caseType: json['caseType']?.toString() ?? '',
      billingType: json['billingType']?.toString() ?? '',
      currencyCode: json['currencyCode']?.toString() ?? 'GBP',
      clientId: json['clientId']?.toString() ?? '',
      feeEarnerId: json['feeEarnerId']?.toString() ?? '',
      partnerId: json['partnerId']?.toString() ?? '',
      personAssistId: json['personAssistId']?.toString() ?? '',
      relationshipManagerId: json['relationshipManagerId']?.toString() ?? '',
      openedOn: DateTime.tryParse(json['openedOn']?.toString() ?? '') ?? DateTime.now(),
      description: json['description']?.toString() ?? '',
    );
  }
}

class MatterQuery {
  const MatterQuery({
    this.search = '',
    this.practicesArea,
    this.caseStatusType,
    this.page = 1,
    this.pageSize = 10,
  });

  final String search;
  final String? practicesArea;
  final String? caseStatusType;
  final int page;
  final int pageSize;

  MatterQuery copyWith({
    String? search,
    String? practicesArea,
    String? caseStatusType,
    int? page,
    int? pageSize,
    bool clearPracticesArea = false,
    bool clearCaseStatus = false,
  }) {
    return MatterQuery(
      search: search ?? this.search,
      practicesArea: clearPracticesArea ? null : practicesArea ?? this.practicesArea,
      caseStatusType: clearCaseStatus ? null : caseStatusType ?? this.caseStatusType,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

/// Who is calling. Mock repositories apply MatterAccess with this context
/// before they return rows. Screens must render the result as-is.
class MatterAccessContext {
  const MatterAccessContext({required this.userId, required this.role});

  final String userId;
  final String role;
}
