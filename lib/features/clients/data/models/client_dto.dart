class ClientDto {
  const ClientDto({
    required this.id,
    required this.clientType,
    required this.displayName,
    this.nameTitle,
    this.firstName,
    this.lastName,
    this.companyName,
    this.trusteeName,
    this.email,
    this.phone,
    this.industryType,
    this.addressType,
    this.country,
    this.clientGroup,
    this.department,
    this.pocList,
    this.companyClients,
    this.customFields = const {},
  });

  final String id;

  /// Individual | Company | Trustee
  final String clientType;
  final String displayName;
  final String? nameTitle;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? trusteeName;
  final String? email;
  final String? phone;
  final String? industryType;
  final String? addressType;
  final String? country;
  final String? clientGroup;
  final String? department;
  final String? pocList;
  final String? companyClients;
  final Map<String, String> customFields;

  factory ClientDto.fromJson(Map<String, dynamic> json) {
    final rawFields = json['customFields'];
    return ClientDto(
      id: json['id'].toString(),
      clientType: json['clientType']?.toString() ?? 'Individual',
      displayName: json['displayName']?.toString() ?? '',
      nameTitle: json['nameTitle']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      companyName: json['companyName']?.toString(),
      trusteeName: json['trusteeName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      industryType: json['industryType']?.toString(),
      addressType: json['addressType']?.toString(),
      country: json['country']?.toString(),
      clientGroup: json['clientGroup']?.toString(),
      department: json['department']?.toString(),
      pocList: json['pocList']?.toString(),
      companyClients: json['companyClients']?.toString(),
      customFields: rawFields is Map
          ? rawFields.map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
    );
  }
}

class CreateIndividualClientRequest {
  const CreateIndividualClientRequest({
    this.nameTitle,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.addressType,
    this.country,
    this.clientGroup,
    this.department,
    this.pocList,
  });

  final String? nameTitle;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? addressType;
  final String? country;
  final String? clientGroup;
  final String? department;
  final String? pocList;

  Map<String, dynamic> toJson() => {
        'clientType': 'Individual',
        'nameTitle': nameTitle,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'addressType': addressType,
        'country': country,
        'clientGroup': clientGroup,
        'department': department,
        'pocList': pocList,
      };
}

class CreateCompanyClientRequest {
  const CreateCompanyClientRequest({
    required this.companyName,
    this.email,
    this.phone,
    this.industryType,
    this.addressType,
    this.country,
    this.clientGroup,
    this.department,
    this.pocList,
  });

  final String companyName;
  final String? email;
  final String? phone;
  final String? industryType;
  final String? addressType;
  final String? country;
  final String? clientGroup;
  final String? department;
  final String? pocList;

  Map<String, dynamic> toJson() => {
        'clientType': 'Company',
        'companyName': companyName,
        'email': email,
        'phone': phone,
        'industryType': industryType,
        'addressType': addressType,
        'country': country,
        'clientGroup': clientGroup,
        'department': department,
        'pocList': pocList,
      };
}

class CreateTrusteeClientRequest {
  const CreateTrusteeClientRequest({
    required this.trusteeName,
    this.nameTitle,
    this.companyClients,
    this.email,
    this.phone,
    this.addressType,
    this.country,
    this.clientGroup,
    this.department,
    this.pocList,
  });

  final String trusteeName;
  final String? nameTitle;
  final String? companyClients;
  final String? email;
  final String? phone;
  final String? addressType;
  final String? country;
  final String? clientGroup;
  final String? department;
  final String? pocList;

  Map<String, dynamic> toJson() => {
        'clientType': 'Trustee',
        'trusteeName': trusteeName,
        'nameTitle': nameTitle,
        'companyClients': companyClients,
        'email': email,
        'phone': phone,
        'addressType': addressType,
        'country': country,
        'clientGroup': clientGroup,
        'department': department,
        'pocList': pocList,
      };
}
