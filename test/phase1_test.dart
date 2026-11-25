import 'package:casetrak_mobile/core/lookups/lookup_keys.dart';
import 'package:casetrak_mobile/core/lookups/lookup_manager.dart';
import 'package:casetrak_mobile/core/lookups/mock_lookup_repo.dart';
import 'package:casetrak_mobile/core/money/forex.dart';
import 'package:casetrak_mobile/core/network/api_exception.dart';
import 'package:casetrak_mobile/features/auth/data/models/login_user.dart';
import 'package:casetrak_mobile/features/clients/data/mock_client_repo.dart';
import 'package:casetrak_mobile/features/clients/data/models/client_dto.dart';
import 'package:casetrak_mobile/features/clients/domain/determine_client_type.dart';
import 'package:casetrak_mobile/features/matters/data/mock_matter_repo.dart';
import 'package:casetrak_mobile/features/matters/data/models/matter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lookup catalogue matches the contract list', () async {
    expect(LookupKeys.all.length, 27);
    expect(LookupKeys.all.toSet().length, 27);
    final manager = LookupManager(MockLookupRepo());
    await manager.batchFetchAll();
    expect(
      manager.get(LookupKeys.clientType).map((item) => item.label),
      ['Individual', 'Company', 'Trustee'],
    );
    expect(manager.isFresh(LookupKeys.country), isTrue);
    manager.invalidateVolatile();
    expect(manager.isCached(LookupKeys.companyClients), isFalse);
    expect(manager.isCached(LookupKeys.country), isTrue);
  });

  test('determineClientType branches trustee, company, then individual', () {
    expect(determineClientType(trusteeName: 'Priya Shah'), 'Trustee');
    expect(determineClientType(companyName: 'Northwind Holdings'), 'Company');
    expect(determineClientType(firstName: 'Jane'), 'Individual');
  });

  test('creating Jane Alden raises DuplicateClientException unless forced', () async {
    final repo = MockClientRepo();
    const request = CreateIndividualClientRequest(
      firstName: 'Jane',
      lastName: 'Alden',
      email: 'jane.alden@example.com',
    );
    expect(
      () => repo.createIndividual(request),
      throwsA(isA<DuplicateClientException>()),
    );
    final created = await repo.createIndividual(request, force: true);
    expect(created.clientType, 'Individual');
    expect(created.id, isNot('c-001'));
  });

  test('matter access is applied inside the repository', () async {
    final repo = MockMatterRepo();
    final assisting = await repo.list(
      const MatterQuery(page: 1, pageSize: 50),
      const MatterAccessContext(userId: 'u-assist', role: UserRole.personAssisting),
    );
    expect(assisting.items, isNotEmpty);
    expect(assisting.items.every((item) => item.personAssistId == 'u-assist'), isTrue);

    final admin = await repo.list(
      const MatterQuery(page: 1, pageSize: 10),
      const MatterAccessContext(userId: 'u-admin', role: UserRole.admin),
    );
    expect(admin.items.length, 10);
    expect(admin.totalCount, 24);
    expect(admin.pageCount, 3);
  });

  test('mixed currencies are summed only after forex conversion', () {
    final forex = ForexTable.seeded();
    final mixed = sumMoney(
      const [Money(100, 'GBP'), Money(127, 'USD')],
      targetCurrency: 'GBP',
      forex: forex,
    );
    expect(mixed.converted, isTrue);
    expect(mixed.total, closeTo(200, 0.001));

    final single = sumMoney(
      const [Money(100, 'GBP'), Money(50, 'GBP')],
      targetCurrency: 'GBP',
      forex: forex,
    );
    expect(single.converted, isFalse);
    expect(single.total, 150);
  });
}
