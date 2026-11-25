class GetMatterPayerDto {
  const GetMatterPayerDto({
    required this.id,
    required this.caseId,
    required this.invoicePortion,
    required this.sendCopy,
    required this.billRecipient,
    required this.relationshipType,
    required this.isDefault,
  });

  final String id;
  final String caseId;
  final double invoicePortion;
  final bool sendCopy;
  final String billRecipient;
  final String relationshipType;
  final bool isDefault;

  GetMatterPayerDto copyWith({
    double? invoicePortion,
    bool? sendCopy,
    String? billRecipient,
    String? relationshipType,
    bool? isDefault,
  }) {
    return GetMatterPayerDto(
      id: id,
      caseId: caseId,
      invoicePortion: invoicePortion ?? this.invoicePortion,
      sendCopy: sendCopy ?? this.sendCopy,
      billRecipient: billRecipient ?? this.billRecipient,
      relationshipType: relationshipType ?? this.relationshipType,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory GetMatterPayerDto.fromJson(Map<String, dynamic> json) {
    return GetMatterPayerDto(
      id: json['id'].toString(),
      caseId: json['caseId'].toString(),
      invoicePortion: _asDouble(json['invoicePortion']),
      sendCopy: json['sendCopy'] == true,
      billRecipient: json['billRecipient']?.toString() ?? '',
      relationshipType: json['relationshipType']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

class CreateMatterPayerRequest {
  const CreateMatterPayerRequest({
    required this.caseId,
    required this.invoicePortion,
    required this.sendCopy,
    required this.billRecipient,
    required this.relationshipType,
    required this.isDefault,
  });

  final String caseId;
  final double invoicePortion;
  final bool sendCopy;
  final String billRecipient;
  final String relationshipType;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
        'invoicePortion': invoicePortion,
        'sendCopy': sendCopy,
        'billRecipient': billRecipient,
        'relationshipType': relationshipType,
        'isDefault': isDefault,
      };
}

class UpdateMatterPayerRequest {
  const UpdateMatterPayerRequest({
    required this.invoicePortion,
    required this.sendCopy,
    required this.billRecipient,
    required this.relationshipType,
    required this.isDefault,
  });

  final double invoicePortion;
  final bool sendCopy;
  final String billRecipient;
  final String relationshipType;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'invoicePortion': invoicePortion,
        'sendCopy': sendCopy,
        'billRecipient': billRecipient,
        'relationshipType': relationshipType,
        'isDefault': isDefault,
      };
}

class MatterPayerResponse {
  const MatterPayerResponse({required this.payer});

  final GetMatterPayerDto payer;

  factory MatterPayerResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['payer'] is Map<String, dynamic> ? json['payer'] as Map<String, dynamic> : json;
    return MatterPayerResponse(payer: GetMatterPayerDto.fromJson(raw));
  }
}

class MatterPayerListResponse {
  const MatterPayerListResponse({required this.items});

  final List<GetMatterPayerDto> items;

  factory MatterPayerListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw.whereType<Map>().map((item) => GetMatterPayerDto.fromJson(_stringKey(item))).toList()
        : <GetMatterPayerDto>[];
    return MatterPayerListResponse(items: items);
  }
}

class GetMatterRelatedContactDto {
  const GetMatterRelatedContactDto({
    required this.id,
    required this.caseId,
    required this.relationshipType,
    required this.isDefaultRecipient,
    required this.isActive,
  });

  final String id;
  final String caseId;
  final String relationshipType;
  final bool isDefaultRecipient;
  final bool isActive;

  factory GetMatterRelatedContactDto.fromJson(Map<String, dynamic> json) {
    return GetMatterRelatedContactDto(
      id: json['id'].toString(),
      caseId: json['caseId'].toString(),
      relationshipType: json['relationshipType']?.toString() ?? '',
      isDefaultRecipient: json['isDefaultRecipient'] == true,
      isActive: json['isActive'] == true,
    );
  }
}

class CreateMatterRelatedContactRequest {
  const CreateMatterRelatedContactRequest({
    required this.caseId,
    required this.relationshipType,
    required this.isDefaultRecipient,
    required this.isActive,
  });

  final String caseId;
  final String relationshipType;
  final bool isDefaultRecipient;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
        'relationshipType': relationshipType,
        'isDefaultRecipient': isDefaultRecipient,
        'isActive': isActive,
      };
}

class UpdateMatterRelatedContactRequest {
  const UpdateMatterRelatedContactRequest({
    required this.relationshipType,
    required this.isDefaultRecipient,
    required this.isActive,
  });

  final String relationshipType;
  final bool isDefaultRecipient;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'relationshipType': relationshipType,
        'isDefaultRecipient': isDefaultRecipient,
        'isActive': isActive,
      };
}

class MatterRelatedContactResponse {
  const MatterRelatedContactResponse({required this.contact});

  final GetMatterRelatedContactDto contact;

  factory MatterRelatedContactResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['contact'] is Map<String, dynamic> ? json['contact'] as Map<String, dynamic> : json;
    return MatterRelatedContactResponse(contact: GetMatterRelatedContactDto.fromJson(raw));
  }
}

class MatterRelatedContactListResponse {
  const MatterRelatedContactListResponse({required this.items});

  final List<GetMatterRelatedContactDto> items;
}

class GetCaseTrustNotificationRecipientDto {
  const GetCaseTrustNotificationRecipientDto({
    required this.id,
    required this.caseId,
    required this.isNotifiedRecipient,
    required this.isActive,
  });

  final String id;
  final String caseId;
  final bool isNotifiedRecipient;
  final bool isActive;

  factory GetCaseTrustNotificationRecipientDto.fromJson(Map<String, dynamic> json) {
    return GetCaseTrustNotificationRecipientDto(
      id: json['id'].toString(),
      caseId: json['caseId'].toString(),
      isNotifiedRecipient: json['isNotifiedRecipient'] == true,
      isActive: json['isActive'] == true,
    );
  }
}

class CreateCaseTrustNotificationRecipientRequest {
  const CreateCaseTrustNotificationRecipientRequest({
    required this.caseId,
    required this.isNotifiedRecipient,
    required this.isActive,
  });

  final String caseId;
  final bool isNotifiedRecipient;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
        'isNotifiedRecipient': isNotifiedRecipient,
        'isActive': isActive,
      };
}

class UpdateCaseTrustNotificationRecipientRequest {
  const UpdateCaseTrustNotificationRecipientRequest({
    required this.isNotifiedRecipient,
    required this.isActive,
  });

  final bool isNotifiedRecipient;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'isNotifiedRecipient': isNotifiedRecipient,
        'isActive': isActive,
      };
}

class CaseTrustNotificationRecipientResponse {
  const CaseTrustNotificationRecipientResponse({required this.recipient});

  final GetCaseTrustNotificationRecipientDto recipient;

  factory CaseTrustNotificationRecipientResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['recipient'] is Map<String, dynamic>
        ? json['recipient'] as Map<String, dynamic>
        : json;
    return CaseTrustNotificationRecipientResponse(
      recipient: GetCaseTrustNotificationRecipientDto.fromJson(raw),
    );
  }
}

class CaseTrustNotificationRecipientListResponse {
  const CaseTrustNotificationRecipientListResponse({required this.items});

  final List<GetCaseTrustNotificationRecipientDto> items;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _stringKey(Map raw) => raw.map((k, v) => MapEntry(k.toString(), v));
