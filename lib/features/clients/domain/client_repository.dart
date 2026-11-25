import '../../../core/models/paged.dart';
import '../data/models/client_dto.dart';

abstract class ClientRepository {
  Future<Paged<ClientDto>> list({
    String search = '',
    String? clientType,
    int page = 1,
    int pageSize = 10,
  });

  Future<ClientDto> getById(String id);

  Future<ClientDto> createIndividual(CreateIndividualClientRequest request, {bool force = false});

  Future<ClientDto> createCompany(CreateCompanyClientRequest request, {bool force = false});

  Future<ClientDto> createTrustee(CreateTrusteeClientRequest request, {bool force = false});

  Future<ClientDto> update(String id, Map<String, dynamic> patch);
}
