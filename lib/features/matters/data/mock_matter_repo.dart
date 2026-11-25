import '../../../core/models/paged.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/models/login_user.dart';
import '../domain/matter_repository.dart';
import 'models/matter.dart';
import 'models/matter_detail.dart';

/// Server-side MatterAccess. Presentation must not call this to re-filter a
/// response the API already scoped.
List<Matter> applyMatterAccess(List<Matter> items, MatterAccessContext access) {
  switch (access.role) {
    case UserRole.relationshipManager:
      return items.where((item) => item.relationshipManagerId == access.userId).toList();
    case UserRole.personAssisting:
      return items.where((item) => item.personAssistId == access.userId).toList();
    default:
      return items;
  }
}

List<Matter> buildSeedMatters() {
  const names = [
    'Northwind share purchase',
    'Harbor lease dispute',
    'Alden estate planning',
    'Rahman employment claim',
    'Priya Shah trust review',
    'City bridge refinancing',
    'Quay Street injunction',
    'Helios supply contract',
    'Brightline redundancy',
    'Oak & Vine conveyance',
    'Meridian JV agreement',
    'Sable IP licence',
    'Westgate possession',
    'Kite Pharma NDA',
    'Lumen board minutes',
    'Arcadia warranty claim',
    'Northwind shareholder dispute',
    'Harbor data protection',
    'Alden lasting power',
    'Rahman settlement',
    'Priya Shah distribution',
    'Forge Metals acquisition',
    'Pell Mell lease renewal',
    'Summit regulatory advice',
  ];
  const areas = [
    'practicesArea-corporate',
    'practicesArea-litigation',
    'practicesArea-employment',
    'practicesArea-real-estate',
    'practicesArea-private-client',
  ];
  const statuses = [
    'caseStatusType-open',
    'caseStatusType-pending',
    'caseStatusType-closed',
    'caseStatusType-on-hold',
  ];
  const caseTypes = [
    'caseType-transaction',
    'caseType-dispute',
    'caseType-advisory',
    'caseType-compliance',
  ];
  const billing = [
    'billingType-hourly',
    'billingType-fixed-fee',
    'billingType-contingent',
  ];
  const clients = ['c-001', 'c-002', 'c-003', 'c-004', 'c-005'];

  return [
    for (var n = 1; n <= names.length; n++)
      Matter(
        id: 'm-${n.toString().padLeft(3, '0')}',
        matterNumber: 'CT-${1000 + n}',
        matterName: names[n - 1],
        practicesArea: areas[(n - 1) % areas.length],
        caseStatusType: statuses[(n - 1) % statuses.length],
        caseType: caseTypes[(n - 1) % caseTypes.length],
        billingType: billing[(n - 1) % billing.length],
        currencyCode: 'GBP',
        clientId: clients[(n - 1) % clients.length],
        feeEarnerId: n.isEven ? 'u-fee' : 'fee-sara',
        partnerId: 'u-partner',
        personAssistId: n % 4 == 0 ? 'u-assist' : 'assist-owen',
        relationshipManagerId: n % 3 == 0 ? 'u-rm' : 'u-partner',
        openedOn: DateTime(2025, ((n - 1) % 12) + 1, (n % 27) + 1),
        description: 'Seeded matter ${names[n - 1]}.',
      ),
  ];
}

class MockMatterRepo implements MatterRepository {
  MockMatterRepo({List<Matter>? seed}) : _items = List<Matter>.of(seed ?? buildSeedMatters());

  final List<Matter> _items;

  @override
  Future<Paged<Matter>> list(MatterQuery query, MatterAccessContext access) async {
    final scoped = applyMatterAccess(_items, access);
    final search = query.search.trim().toLowerCase();
    final filtered = scoped.where((matter) {
      final matchesSearch = search.isEmpty ||
          matter.matterName.toLowerCase().contains(search) ||
          matter.matterNumber.toLowerCase().contains(search) ||
          matter.description.toLowerCase().contains(search);
      final matchesArea = query.practicesArea == null || matter.practicesArea == query.practicesArea;
      final matchesStatus =
          query.caseStatusType == null || matter.caseStatusType == query.caseStatusType;
      return matchesSearch && matchesArea && matchesStatus;
    }).toList();

    final start = (query.page - 1) * query.pageSize;
    final slice = start >= filtered.length
        ? const <Matter>[]
        : filtered.skip(start).take(query.pageSize).toList();
    return Paged(
      items: slice,
      page: query.page,
      pageSize: query.pageSize,
      totalCount: filtered.length,
    );
  }

  @override
  Future<MatterDetail> getById(String id, MatterAccessContext access) async {
    final scoped = applyMatterAccess(_items, access);
    final matter = scoped.where((item) => item.id == id).firstOrNull;
    if (matter == null) {
      throw ApiException('Matter not found');
    }
    return _detailFor(matter);
  }

  @override
  Future<List<Matter>> forClient(String clientId, MatterAccessContext access) async {
    final scoped = applyMatterAccess(_items, access);
    return scoped.where((item) => item.clientId == clientId).toList();
  }
}

MatterDetail _detailFor(Matter matter) {
  final opened = matter.openedOn;
  return MatterDetail(
    matter: matter,
    time: [
      MatterTimeRow(
        id: '${matter.id}-t1',
        workedOn: opened.add(const Duration(days: 3)),
        feeEarnerId: matter.feeEarnerId,
        description: 'Initial review and client call',
        hours: 1.5,
      ),
      MatterTimeRow(
        id: '${matter.id}-t2',
        workedOn: opened.add(const Duration(days: 10)),
        feeEarnerId: matter.feeEarnerId,
        description: 'Drafting and research',
        hours: 2.4,
      ),
    ],
    invoices: [
      MatterInvoiceRow(
        id: '${matter.id}-i1',
        number: 'INV-${matter.matterNumber}',
        issuedOn: opened.add(const Duration(days: 20)),
        amount: 2400,
        currencyCode: matter.currencyCode,
        status: 'Unpaid',
      ),
      MatterInvoiceRow(
        id: '${matter.id}-i2',
        number: 'INV-${matter.matterNumber}-B',
        issuedOn: opened.add(const Duration(days: 40)),
        amount: 860,
        currencyCode: matter.currencyCode,
        status: 'Paid',
      ),
    ],
    expenses: [
      MatterExpenseRow(
        id: '${matter.id}-e1',
        expenseType: 'expenseType-search',
        incurredOn: opened.add(const Duration(days: 6)),
        amount: 42,
        currencyCode: matter.currencyCode,
        description: 'Company search',
      ),
    ],
    documents: [
      MatterDocumentRow(
        id: '${matter.id}-d1',
        name: 'Engagement letter.pdf',
        addedOn: opened,
        kind: 'PDF',
      ),
      MatterDocumentRow(
        id: '${matter.id}-d2',
        name: 'Draft advice.docx',
        addedOn: opened.add(const Duration(days: 12)),
        kind: 'DOCX',
      ),
    ],
    communications: [
      MatterCommunicationRow(
        id: '${matter.id}-c1',
        channel: 'Email',
        subject: 'Engagement confirmed',
        at: opened.add(const Duration(days: 1)),
      ),
    ],
    timeline: [
      MatterTimelineEvent(
        id: '${matter.id}-tl1',
        title: 'Matter opened',
        detail: matter.matterNumber,
        at: opened,
      ),
      MatterTimelineEvent(
        id: '${matter.id}-tl2',
        title: 'Advice drafted',
        detail: 'First draft circulated',
        at: opened.add(const Duration(days: 12)),
      ),
      MatterTimelineEvent(
        id: '${matter.id}-tl3',
        title: 'Invoice issued',
        detail: 'INV-${matter.matterNumber}',
        at: opened.add(const Duration(days: 20)),
      ),
    ],
  );
}
