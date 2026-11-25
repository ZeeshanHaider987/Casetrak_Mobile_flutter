import '../../../core/format/format.dart';
import '../../matters/data/mock_matter_repo.dart';
import '../../matters/data/models/matter.dart';
import '../domain/dashboard_repository.dart';
import 'models/dashboard_data.dart';

class MockDashboardRepo implements DashboardRepository {
  @override
  Future<DashboardData> load(MatterAccessContext access) async {
    final matters = applyMatterAccess(buildSeedMatters(), access);
    final open = matters.where((item) => item.caseStatusType == 'caseStatusType-open').length;
    final now = DateTime.now();
    final deadlines = [
      for (var i = 0; i < matters.length && i < 6; i++)
        DashboardDeadline(
          id: '${matters[i].id}-due',
          matterId: matters[i].id,
          title: matters[i].matterName,
          dueOn: now.add(Duration(days: i + 1)),
        ),
    ];
    final thisWeek = deadlines.where((item) => item.dueOn.difference(now).inDays < 7).length;

    return DashboardData(
      kpis: [
        DashboardKpi(label: 'Open matters', value: '$open'),
        DashboardKpi(label: 'Deadlines this week', value: '$thisWeek'),
        DashboardKpi(
          label: 'Unbilled WIP',
          value: formatMoney(matters.length * 860, 'GBP'),
          footnote: 'GBP',
        ),
        DashboardKpi(
          label: 'Unpaid invoices',
          value: formatMoney(matters.length * 2400, 'GBP'),
          footnote: 'GBP',
        ),
      ],
      deadlines: deadlines,
      activity: [
        for (final matter in matters.take(6))
          DashboardActivity(
            id: '${matter.id}-act',
            matterId: matter.id,
            title: matter.matterName,
            detail: '${matter.matterNumber} updated',
            at: matter.openedOn,
          ),
      ],
    );
  }
}
