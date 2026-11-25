import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'client_providers.dart';

class ClientCreationSuccess extends ConsumerWidget {
  const ClientCreationSuccess({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientDetailProvider(clientId));
    final name = client.valueOrNull?.displayName ?? 'Client';
    return Scaffold(
      appBar: AppBar(title: const Text('Client created')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline, size: 48),
            const SizedBox(height: 12),
            Text('$name is ready.', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('You can open the client record or start a matter.'),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/clients/$clientId'),
              child: const Text('View client'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go('/matters'),
              child: const Text('Create matter now?'),
            ),
          ],
        ),
      ),
    );
  }
}
