import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/format.dart';
import '../../../core/lookups/lookup_keys.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/lookup_dropdown.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../parties/presentation/parties_tab.dart';
import '../data/models/matter_detail.dart';
import 'matter_providers.dart';

class MatterDetailScreen extends ConsumerWidget {
  const MatterDetailScreen({super.key, required this.matterId});

  final String matterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(matterDetailProvider(matterId));
    return detail.when(
      loading: () => const Scaffold(body: SkeletonList()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Matter')),
        body: ErrorRetry(
          message: error.toString(),
          onRetry: () => ref.invalidate(matterDetailProvider(matterId)),
        ),
      ),
      data: (data) => DefaultTabController(
        length: 8,
        child: Scaffold(
          appBar: AppBar(
            title: Text(data.matter.matterName),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Parties'),
                Tab(text: 'Time'),
                Tab(text: 'Invoices'),
                Tab(text: 'Expenses'),
                Tab(text: 'Documents'),
                Tab(text: 'Communications'),
                Tab(text: 'Timeline'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OverviewTab(detail: data),
              PartiesTab(caseId: data.matter.id),
              TimeLedgerTab(rows: data.time),
              InvoicesTab(rows: data.invoices),
              ExpensesTab(rows: data.expenses),
              DocumentsTab(rows: data.documents),
              CommunicationsTab(rows: data.communications),
              TimelineTab(events: data.timeline),
            ],
          ),
        ),
      ),
    );
  }
}

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key, required this.detail});

  final MatterDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(lookupManagerProvider);
    final matter = detail.matter;
    final rows = [
      ('Number', matter.matterNumber),
      ('Practice area', lookupLabel(manager, LookupKeys.practicesArea, matter.practicesArea)),
      ('Status', lookupLabel(manager, LookupKeys.caseStatusType, matter.caseStatusType)),
      ('Case type', lookupLabel(manager, LookupKeys.caseType, matter.caseType)),
      ('Billing', lookupLabel(manager, LookupKeys.billingType, matter.billingType)),
      ('Currency', matter.currencyCode),
      ('Opened', formatDate(matter.openedOn)),
      ('Description', matter.description),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final row in rows)
          Card(
            child: ListTile(
              title: Text(row.$1),
              subtitle: Text(row.$2),
            ),
          ),
      ],
    );
  }
}

class TimeLedgerTab extends ConsumerWidget {
  const TimeLedgerTab({super.key, required this.rows});

  final List<MatterTimeRow> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(lookupManagerProvider);
    if (rows.isEmpty) {
      return const EmptyState(title: 'No recorded time', icon: Icons.schedule_outlined);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Recorded time', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final row in rows)
          Card(
            child: ListTile(
              title: Text(row.description),
              subtitle: Text(
                '${formatDate(row.workedOn)} · ${lookupLabel(manager, LookupKeys.feeEarnerList, row.feeEarnerId)}',
              ),
              trailing: Text('${row.hours} h'),
            ),
          ),
      ],
    );
  }
}

class InvoicesTab extends StatelessWidget {
  const InvoicesTab({super.key, required this.rows});

  final List<MatterInvoiceRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const EmptyState(title: 'No invoices', icon: Icons.receipt_long_outlined);
    }
    final totals = <String, double>{};
    for (final row in rows) {
      totals[row.currencyCode] = (totals[row.currencyCode] ?? 0) + row.amount;
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final row in rows)
          Card(
            child: ListTile(
              title: Text(row.number),
              subtitle: Text('${formatDate(row.issuedOn)} · ${row.status}'),
              trailing: Text(formatMoney(row.amount, row.currencyCode)),
            ),
          ),
        const SizedBox(height: 8),
        for (final entry in totals.entries)
          ListTile(
            title: Text('Total ${entry.key}'),
            trailing: Text(formatMoney(entry.value, entry.key)),
          ),
      ],
    );
  }
}

class ExpensesTab extends ConsumerWidget {
  const ExpensesTab({super.key, required this.rows});

  final List<MatterExpenseRow> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(lookupManagerProvider);
    if (rows.isEmpty) {
      return const EmptyState(title: 'No expenses', icon: Icons.payments_outlined);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final row in rows)
          Card(
            child: ListTile(
              title: Text(row.description),
              subtitle: Text(
                '${lookupLabel(manager, LookupKeys.expenseType, row.expenseType)} · ${formatDate(row.incurredOn)}',
              ),
              trailing: Text(formatMoney(row.amount, row.currencyCode)),
            ),
          ),
      ],
    );
  }
}

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key, required this.rows});

  final List<MatterDocumentRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const EmptyState(title: 'No documents', icon: Icons.description_outlined);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final row in rows)
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(row.name),
              subtitle: Text('${row.kind} · ${formatDate(row.addedOn)}'),
            ),
          ),
      ],
    );
  }
}

class CommunicationsTab extends StatelessWidget {
  const CommunicationsTab({super.key, required this.rows});

  final List<MatterCommunicationRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const EmptyState(title: 'No communications', icon: Icons.forum_outlined);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final row in rows)
          Card(
            child: ListTile(
              title: Text(row.subject),
              subtitle: Text('${row.channel} · ${formatDateTime(row.at)}'),
            ),
          ),
      ],
    );
  }
}

class TimelineTab extends StatelessWidget {
  const TimelineTab({super.key, required this.events});

  final List<MatterTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyState(title: 'No timeline events', icon: Icons.timeline_outlined);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final event in events)
          Card(
            child: ListTile(
              title: Text(event.title),
              subtitle: Text(event.detail),
              trailing: Text(formatDate(event.at), style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
      ],
    );
  }
}
