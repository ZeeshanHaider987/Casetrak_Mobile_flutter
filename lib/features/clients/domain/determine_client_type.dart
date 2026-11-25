import '../data/models/client_dto.dart';

/// Mirrors the web app's `determineClientType` helper.
/// Trustee wins over company, company wins over individual.
String determineClientType({
  String? trusteeName,
  String? companyName,
  String? firstName,
}) {
  if (trusteeName != null && trusteeName.trim().isNotEmpty) return 'Trustee';
  if (companyName != null && companyName.trim().isNotEmpty) return 'Company';
  if (firstName != null && firstName.trim().isNotEmpty) return 'Individual';
  return 'Individual';
}

String determineClientTypeFromDto(ClientDto client) {
  return determineClientType(
    trusteeName: client.clientType == 'Trustee' ? client.trusteeName ?? client.displayName : null,
    companyName: client.clientType == 'Company' ? client.companyName ?? client.displayName : null,
    firstName: client.firstName ?? (client.clientType == 'Individual' ? client.displayName : null),
  );
}
