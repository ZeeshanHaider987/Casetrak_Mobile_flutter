import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/case_trak_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../auth/presentation/auth_controller.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final name = ref.watch(authControllerProvider).valueOrNull?.user.displayName ?? '';

    return Scaffold(
      appBar: const CaseTrakAppBar(title: 'Dashboard'),
      body: dashboard.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorRetry(
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Hello, $name', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Firm snapshot',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                for (final kpi in data.kpis) _KpiCard(label: kpi.label, value: kpi.value, footnote: kpi.footnote),
              ],
            ),
            const SizedBox(height: 20),
            Text('Upcoming deadlines', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (data.deadlines.isEmpty)
              const EmptyState(title: 'No upcoming deadlines', icon: Icons.event_available_outlined)
            else
              Card(
                child: Column(
                  children: [
                    for (final item in data.deadlines)
                      ListTile(
                        leading: const Icon(Icons.event_outlined, color: AppTheme.ink),
                        title: Text(item.title),
                        subtitle: Text(formatDate(item.dueOn)),
                        onTap: () => context.push('/matters/${item.matterId}'),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (data.activity.isEmpty)
              const EmptyState(title: 'No recent activity', icon: Icons.history)
            else
              Card(
                child: Column(
                  children: [
                    for (final item in data.activity)
                      ListTile(
                        leading: const Icon(Icons.history, color: AppTheme.brass),
                        title: Text(item.title),
                        subtitle: Text(item.detail),
                        trailing: Text(formatDate(item.at), style: Theme.of(context).textTheme.labelSmall),
                        onTap: () => context.push('/matters/${item.matterId}'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, this.footnote});

  final String label;
  final String value;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            if (footnote != null)
              Text(
                footnote!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
