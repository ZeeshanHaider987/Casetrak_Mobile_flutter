import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../data/models/party_dtos.dart';
import 'parties_providers.dart';

class PartiesTab extends ConsumerWidget {
  const PartiesTab({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parties = ref.watch(partiesProvider(caseId));
    return parties.when(
      loading: () => const SkeletonList(rows: 4),
      error: (error, _) => ErrorRetry(
        message: error.toString(),
        onRetry: () => ref.invalidate(partiesProvider(caseId)),
      ),
      data: (snapshot) => DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Payers'),
                Tab(text: 'Related'),
                Tab(text: 'Trust'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PayerList(caseId: caseId, items: snapshot.payers),
                  _RelatedList(caseId: caseId, items: snapshot.related),
                  _TrustList(caseId: caseId, items: snapshot.trust),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayerList extends ConsumerWidget {
  const _PayerList({required this.caseId, required this.items});

  final String caseId;
  final List<GetMatterPayerDto> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PartyScaffold(
      empty: 'No payers',
      onAdd: () => _editPayer(context, ref, caseId),
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              title: Text(item.billRecipient),
              subtitle: Text(
                'invoicePortion ${item.invoicePortion} · ${item.relationshipType}'
                '${item.sendCopy ? ' · sendCopy' : ''}'
                '${item.isDefault ? ' · isDefault' : ''}',
              ),
              onTap: () => _editPayer(context, ref, caseId, existing: item),
              trailing: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _remove(
                  context,
                  'Remove this payer?',
                  () => ref.read(partiesProvider(caseId).notifier).deletePayer(item.id),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RelatedList extends ConsumerWidget {
  const _RelatedList({required this.caseId, required this.items});

  final String caseId;
  final List<GetMatterRelatedContactDto> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PartyScaffold(
      empty: 'No related contacts',
      onAdd: () => _editRelated(context, ref, caseId),
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              title: Text(item.relationshipType),
              subtitle: Text(
                'isDefaultRecipient ${item.isDefaultRecipient} · isActive ${item.isActive}',
              ),
              onTap: () => _editRelated(context, ref, caseId, existing: item),
              trailing: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _remove(
                  context,
                  'Remove this contact?',
                  () => ref.read(partiesProvider(caseId).notifier).deleteRelated(item.id),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TrustList extends ConsumerWidget {
  const _TrustList({required this.caseId, required this.items});

  final String caseId;
  final List<GetCaseTrustNotificationRecipientDto> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PartyScaffold(
      empty: 'No trust recipients',
      onAdd: () => _editTrust(context, ref, caseId),
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              title: Text(item.isNotifiedRecipient ? 'Notified recipient' : 'Recipient'),
              subtitle: Text('isNotifiedRecipient ${item.isNotifiedRecipient} · isActive ${item.isActive}'),
              onTap: () => _editTrust(context, ref, caseId, existing: item),
              trailing: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _remove(
                  context,
                  'Remove this recipient?',
                  () => ref.read(partiesProvider(caseId).notifier).deleteTrust(item.id),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PartyScaffold extends StatelessWidget {
  const _PartyScaffold({
    required this.empty,
    required this.onAdd,
    required this.children,
  });

  final String empty;
  final VoidCallback onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (children.isEmpty)
          EmptyState(title: empty, action: OutlinedButton(onPressed: onAdd, child: const Text('Add')))
        else
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: children,
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            onPressed: onAdd,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

Future<void> _remove(BuildContext context, String title, Future<void> Function() action) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed ?? false) await action();
}

Future<void> _editPayer(
  BuildContext context,
  WidgetRef ref,
  String caseId, {
  GetMatterPayerDto? existing,
}) async {
  final recipient = TextEditingController(text: existing?.billRecipient ?? '');
  final relationship = TextEditingController(text: existing?.relationshipType ?? '');
  final portion = TextEditingController(text: existing?.invoicePortion.toString() ?? '');
  var sendCopy = existing?.sendCopy ?? false;
  var isDefault = existing?.isDefault ?? false;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return _SheetFrame(
          title: existing == null ? 'Add payer' : 'Edit payer',
          onSave: () => Navigator.pop(context, true),
          children: [
            TextField(controller: recipient, decoration: const InputDecoration(labelText: 'billRecipient')),
            const SizedBox(height: 12),
            TextField(controller: relationship, decoration: const InputDecoration(labelText: 'relationshipType')),
            const SizedBox(height: 12),
            TextField(
              controller: portion,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'invoicePortion'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('sendCopy'),
              value: sendCopy,
              onChanged: (value) => setState(() => sendCopy = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('isDefault'),
              value: isDefault,
              onChanged: (value) => setState(() => isDefault = value),
            ),
          ],
        );
      },
    ),
  );

  if (saved ?? false) {
    final invoicePortion = double.tryParse(portion.text.trim()) ?? 0;
    final notifier = ref.read(partiesProvider(caseId).notifier);
    if (existing == null) {
      await notifier.createPayer(
        CreateMatterPayerRequest(
          caseId: caseId,
          invoicePortion: invoicePortion,
          sendCopy: sendCopy,
          billRecipient: recipient.text.trim(),
          relationshipType: relationship.text.trim(),
          isDefault: isDefault,
        ),
      );
    } else {
      await notifier.updatePayer(
        existing.id,
        UpdateMatterPayerRequest(
          invoicePortion: invoicePortion,
          sendCopy: sendCopy,
          billRecipient: recipient.text.trim(),
          relationshipType: relationship.text.trim(),
          isDefault: isDefault,
        ),
      );
    }
  }
  recipient.dispose();
  relationship.dispose();
  portion.dispose();
}

Future<void> _editRelated(
  BuildContext context,
  WidgetRef ref,
  String caseId, {
  GetMatterRelatedContactDto? existing,
}) async {
  final relationship = TextEditingController(text: existing?.relationshipType ?? '');
  var isDefaultRecipient = existing?.isDefaultRecipient ?? false;
  var isActive = existing?.isActive ?? true;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _SheetFrame(
        title: existing == null ? 'Add related contact' : 'Edit related contact',
        onSave: () => Navigator.pop(context, true),
        children: [
          TextField(controller: relationship, decoration: const InputDecoration(labelText: 'relationshipType')),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('isDefaultRecipient'),
            value: isDefaultRecipient,
            onChanged: (value) => setState(() => isDefaultRecipient = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('isActive'),
            value: isActive,
            onChanged: (value) => setState(() => isActive = value),
          ),
        ],
      ),
    ),
  );
  if (saved ?? false) {
    final notifier = ref.read(partiesProvider(caseId).notifier);
    if (existing == null) {
      await notifier.createRelated(
        CreateMatterRelatedContactRequest(
          caseId: caseId,
          relationshipType: relationship.text.trim(),
          isDefaultRecipient: isDefaultRecipient,
          isActive: isActive,
        ),
      );
    } else {
      await notifier.updateRelated(
        existing.id,
        UpdateMatterRelatedContactRequest(
          relationshipType: relationship.text.trim(),
          isDefaultRecipient: isDefaultRecipient,
          isActive: isActive,
        ),
      );
    }
  }
  relationship.dispose();
}

Future<void> _editTrust(
  BuildContext context,
  WidgetRef ref,
  String caseId, {
  GetCaseTrustNotificationRecipientDto? existing,
}) async {
  var isNotifiedRecipient = existing?.isNotifiedRecipient ?? true;
  var isActive = existing?.isActive ?? true;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _SheetFrame(
        title: existing == null ? 'Add trust recipient' : 'Edit trust recipient',
        onSave: () => Navigator.pop(context, true),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('isNotifiedRecipient'),
            value: isNotifiedRecipient,
            onChanged: (value) => setState(() => isNotifiedRecipient = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('isActive'),
            value: isActive,
            onChanged: (value) => setState(() => isActive = value),
          ),
        ],
      ),
    ),
  );
  if (saved ?? false) {
    final notifier = ref.read(partiesProvider(caseId).notifier);
    if (existing == null) {
      await notifier.createTrust(
        CreateCaseTrustNotificationRecipientRequest(
          caseId: caseId,
          isNotifiedRecipient: isNotifiedRecipient,
          isActive: isActive,
        ),
      );
    } else {
      await notifier.updateTrust(
        existing.id,
        UpdateCaseTrustNotificationRecipientRequest(
          isNotifiedRecipient: isNotifiedRecipient,
          isActive: isActive,
        ),
      );
    }
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.children, required this.onSave});

  final String title;
  final List<Widget> children;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...children,
          const SizedBox(height: 12),
          FilledButton(onPressed: onSave, child: const Text('Save')),
        ],
      ),
    );
  }
}
