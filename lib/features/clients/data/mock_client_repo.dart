import '../../../core/models/paged.dart';
import '../../../core/network/api_exception.dart';
import '../domain/client_repository.dart';
import '../domain/determine_client_type.dart';
import 'models/client_dto.dart';

class MockClientRepo implements ClientRepository {
  MockClientRepo({List<ClientDto>? seed}) : _items = List<ClientDto>.of(seed ?? buildSeedClients());

  final List<ClientDto> _items;
  var _seq = 6;

  @override
  Future<Paged<ClientDto>> list({
    String search = '',
    String? clientType,
    int page = 1,
    int pageSize = 10,
  }) async {
    final needle = search.trim().toLowerCase();
    final filtered = _items.where((client) {
      final matchesType = clientType == null || client.clientType == clientType;
      final matchesSearch = needle.isEmpty ||
          client.displayName.toLowerCase().contains(needle) ||
          (client.email ?? '').toLowerCase().contains(needle);
      return matchesType && matchesSearch;
    }).toList();
    final start = (page - 1) * pageSize;
    final slice = start >= filtered.length
        ? const <ClientDto>[]
        : filtered.skip(start).take(pageSize).toList();
    return Paged(items: slice, page: page, pageSize: pageSize, totalCount: filtered.length);
  }

  @override
  Future<ClientDto> getById(String id) async {
    final client = _items.where((item) => item.id == id).firstOrNull;
    if (client == null) throw ApiException('Client not found');
    return client;
  }

  @override
  Future<ClientDto> createIndividual(CreateIndividualClientRequest request, {bool force = false}) async {
    _requireEmail(request.email);
    if (request.firstName.trim().isEmpty || request.lastName.trim().isEmpty) {
      throw InvalidClientException({
        if (request.firstName.trim().isEmpty) 'firstName': 'Enter a first name',
        if (request.lastName.trim().isEmpty) 'lastName': 'Enter a last name',
      });
    }
    if (!force && _isJaneAlden(request.firstName, request.lastName)) {
      throw DuplicateClientException(existingClientId: 'c-001');
    }
    final created = ClientDto(
      id: 'c-${(_seq++).toString().padLeft(3, '0')}',
      clientType: determineClientType(firstName: request.firstName),
      displayName: '${request.firstName.trim()} ${request.lastName.trim()}',
      nameTitle: request.nameTitle,
      firstName: request.firstName.trim(),
      lastName: request.lastName.trim(),
      email: request.email,
      phone: request.phone,
      addressType: request.addressType,
      country: request.country,
      clientGroup: request.clientGroup,
      department: request.department,
      pocList: request.pocList,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<ClientDto> createCompany(CreateCompanyClientRequest request, {bool force = false}) async {
    _requireEmail(request.email);
    if (request.companyName.trim().isEmpty) {
      throw InvalidClientException({'companyName': 'Enter a company name'});
    }
    final created = ClientDto(
      id: 'c-${(_seq++).toString().padLeft(3, '0')}',
      clientType: determineClientType(companyName: request.companyName),
      displayName: request.companyName.trim(),
      companyName: request.companyName.trim(),
      email: request.email,
      phone: request.phone,
      industryType: request.industryType,
      addressType: request.addressType,
      country: request.country,
      clientGroup: request.clientGroup,
      department: request.department,
      pocList: request.pocList,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<ClientDto> createTrustee(CreateTrusteeClientRequest request, {bool force = false}) async {
    _requireEmail(request.email);
    final errors = <String, String>{};
    if (request.trusteeName.trim().isEmpty) errors['trusteeName'] = 'Enter the trustee name';
    if (request.companyClients == null || request.companyClients!.isEmpty) {
      errors['companyClients'] = 'Choose a company';
    }
    if (errors.isNotEmpty) throw InvalidClientException(errors);
    final created = ClientDto(
      id: 'c-${(_seq++).toString().padLeft(3, '0')}',
      clientType: determineClientType(trusteeName: request.trusteeName),
      displayName: request.trusteeName.trim(),
      trusteeName: request.trusteeName.trim(),
      nameTitle: request.nameTitle,
      companyClients: request.companyClients,
      email: request.email,
      phone: request.phone,
      addressType: request.addressType,
      country: request.country,
      clientGroup: request.clientGroup,
      department: request.department,
      pocList: request.pocList,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<ClientDto> update(String id, Map<String, dynamic> patch) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) throw ApiException('Client not found');
    final current = _items[index];
    final json = current.toJson()..addAll(patch);
    final updated = ClientDto.fromJson(json);
    _items[index] = updated;
    return updated;
  }

  bool _isJaneAlden(String first, String last) {
    return first.trim().toLowerCase() == 'jane' && last.trim().toLowerCase() == 'alden';
  }

  void _requireEmail(String? email) {
    if (email == null || !email.contains('@') || !email.contains('.')) {
      throw InvalidClientException({'email': 'Enter a valid email'});
    }
  }
}

List<ClientDto> buildSeedClients() {
  return const [
    ClientDto(
      id: 'c-001',
      clientType: 'Individual',
      displayName: 'Jane Alden',
      nameTitle: 'nameTitle-ms',
      firstName: 'Jane',
      lastName: 'Alden',
      email: 'jane.alden@example.com',
      phone: '+44 20 7946 0101',
      addressType: 'addressType-residential',
      country: 'country-gb',
      clientGroup: 'clientGroup-key',
      department: 'department-private-client',
      pocList: 'poc-amelia',
      customFields: {'referredBy': 'Helen Croft'},
    ),
    ClientDto(
      id: 'c-002',
      clientType: 'Individual',
      displayName: 'Omar Rahman',
      nameTitle: 'nameTitle-mr',
      firstName: 'Omar',
      lastName: 'Rahman',
      email: 'omar.rahman@example.com',
      phone: '+44 20 7946 0102',
      addressType: 'addressType-correspondence',
      country: 'country-gb',
      clientGroup: 'clientGroup-standard',
      department: 'department-dispute-resolution',
      pocList: 'poc-david',
      customFields: {'preferredContact': 'Email'},
    ),
    ClientDto(
      id: 'c-003',
      clientType: 'Company',
      displayName: 'Northwind Holdings',
      companyName: 'Northwind Holdings',
      email: 'legal@northwind.example',
      phone: '+44 20 7946 0201',
      industryType: 'industryType-financial-services',
      addressType: 'addressType-registered',
      country: 'country-gb',
      clientGroup: 'clientGroup-key',
      department: 'department-corporate',
      pocList: 'poc-sofia',
      customFields: {'companyNumber': '10442218'},
    ),
    ClientDto(
      id: 'c-004',
      clientType: 'Company',
      displayName: 'Harbor & Co',
      companyName: 'Harbor & Co',
      email: 'office@harbor.example',
      phone: '+44 161 496 0202',
      industryType: 'industryType-real-estate',
      addressType: 'addressType-billing',
      country: 'country-gb',
      clientGroup: 'clientGroup-standard',
      department: 'department-corporate',
      pocList: 'poc-owen',
      customFields: {'companyNumber': '08881234'},
    ),
    ClientDto(
      id: 'c-005',
      clientType: 'Trustee',
      displayName: 'Priya Shah',
      trusteeName: 'Priya Shah',
      nameTitle: 'nameTitle-ms',
      companyClients: 'c-003',
      email: 'priya.shah@example.com',
      phone: '+44 20 7946 0305',
      addressType: 'addressType-correspondence',
      country: 'country-gb',
      clientGroup: 'clientGroup-key',
      department: 'department-private-client',
      pocList: 'poc-amelia',
      customFields: {'trustName': 'Shah Family Trust'},
    ),
  ];
}

extension on ClientDto {
  Map<String, dynamic> toJson() => {
        'id': id,
        'clientType': clientType,
        'displayName': displayName,
        'nameTitle': nameTitle,
        'firstName': firstName,
        'lastName': lastName,
        'companyName': companyName,
        'trusteeName': trusteeName,
        'email': email,
        'phone': phone,
        'industryType': industryType,
        'addressType': addressType,
        'country': country,
        'clientGroup': clientGroup,
        'department': department,
        'pocList': pocList,
        'companyClients': companyClients,
        'customFields': customFields,
      };
}
