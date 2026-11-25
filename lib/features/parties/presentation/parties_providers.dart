import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../clients/presentation/client_providers.dart';
import '../data/mock_parties_repo.dart';
import '../data/models/party_dtos.dart';
import '../data/remote_parties_repo.dart';
import '../domain/parties_repository.dart';

final partiesRepositoryProvider = Provider<PartiesRepository>((ref) {
  if (AppConfig.useMock) return MockPartiesRepo();
  return RemotePartiesRepo(ref.watch(dioProvider));
});

class PartiesSnapshot {
  const PartiesSnapshot({
    required this.payers,
    required this.related,
    required this.trust,
  });

  final List<GetMatterPayerDto> payers;
  final List<GetMatterRelatedContactDto> related;
  final List<GetCaseTrustNotificationRecipientDto> trust;

  PartiesSnapshot copyWith({
    List<GetMatterPayerDto>? payers,
    List<GetMatterRelatedContactDto>? related,
    List<GetCaseTrustNotificationRecipientDto>? trust,
  }) {
    return PartiesSnapshot(
      payers: payers ?? this.payers,
      related: related ?? this.related,
      trust: trust ?? this.trust,
    );
  }
}

class PartiesController extends FamilyAsyncNotifier<PartiesSnapshot, String> {
  @override
  Future<PartiesSnapshot> build(String caseId) => _load(caseId);

  Future<PartiesSnapshot> _load(String caseId) async {
    final repo = ref.read(partiesRepositoryProvider);
    final payers = await repo.listPayers(caseId);
    final related = await repo.listRelated(caseId);
    final trust = await repo.listTrust(caseId);
    return PartiesSnapshot(
      payers: payers.items,
      related: related.items,
      trust: trust.items,
    );
  }

  Future<void> createPayer(CreateMatterPayerRequest request) => _optimistic(
        apply: (current) => current.copyWith(
          payers: [
            ...current.payers,
            GetMatterPayerDto(
              id: 'temp-payer',
              caseId: request.caseId,
              invoicePortion: request.invoicePortion,
              sendCopy: request.sendCopy,
              billRecipient: request.billRecipient,
              relationshipType: request.relationshipType,
              isDefault: request.isDefault,
            ),
          ],
        ),
        persist: () => ref.read(partiesRepositoryProvider).createPayer(request),
      );

  Future<void> deletePayer(String id) async {
    final confirmed = state.valueOrNull;
    if (confirmed == null) return;
    state = AsyncData(confirmed.copyWith(
      payers: confirmed.payers.where((item) => item.id != id).toList(),
    ));
    try {
      await ref.read(partiesRepositoryProvider).deletePayer(id);
      ref.invalidateSelf();
      await future;
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> updatePayer(String id, UpdateMatterPayerRequest request) async {
    await ref.read(partiesRepositoryProvider).updatePayer(id, request);
    ref.invalidateSelf();
    await future;
  }

  Future<void> createRelated(CreateMatterRelatedContactRequest request) => _optimistic(
        apply: (current) => current.copyWith(
          related: [
            ...current.related,
            GetMatterRelatedContactDto(
              id: 'temp-rel',
              caseId: request.caseId,
              relationshipType: request.relationshipType,
              isDefaultRecipient: request.isDefaultRecipient,
              isActive: request.isActive,
            ),
          ],
        ),
        persist: () => ref.read(partiesRepositoryProvider).createRelated(request),
      );

  Future<void> deleteRelated(String id) async {
    final confirmed = state.valueOrNull;
    if (confirmed == null) return;
    state = AsyncData(confirmed.copyWith(
      related: confirmed.related.where((item) => item.id != id).toList(),
    ));
    try {
      await ref.read(partiesRepositoryProvider).deleteRelated(id);
      ref.invalidateSelf();
      await future;
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> updateRelated(String id, UpdateMatterRelatedContactRequest request) async {
    await ref.read(partiesRepositoryProvider).updateRelated(id, request);
    ref.invalidateSelf();
    await future;
  }

  Future<void> createTrust(CreateCaseTrustNotificationRecipientRequest request) => _optimistic(
        apply: (current) => current.copyWith(
          trust: [
            ...current.trust,
            GetCaseTrustNotificationRecipientDto(
              id: 'temp-trust',
              caseId: request.caseId,
              isNotifiedRecipient: request.isNotifiedRecipient,
              isActive: request.isActive,
            ),
          ],
        ),
        persist: () => ref.read(partiesRepositoryProvider).createTrust(request),
      );

  Future<void> deleteTrust(String id) async {
    final confirmed = state.valueOrNull;
    if (confirmed == null) return;
    state = AsyncData(confirmed.copyWith(
      trust: confirmed.trust.where((item) => item.id != id).toList(),
    ));
    try {
      await ref.read(partiesRepositoryProvider).deleteTrust(id);
      ref.invalidateSelf();
      await future;
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> updateTrust(String id, UpdateCaseTrustNotificationRecipientRequest request) async {
    await ref.read(partiesRepositoryProvider).updateTrust(id, request);
    ref.invalidateSelf();
    await future;
  }

  Future<void> _optimistic({
    required PartiesSnapshot Function(PartiesSnapshot current) apply,
    required Future<Object> Function() persist,
  }) async {
    final confirmed = state.valueOrNull;
    if (confirmed == null) return;
    state = AsyncData(apply(confirmed));
    try {
      await persist();
      ref.invalidateSelf();
      await future;
    } catch (error, stack) {
      state = AsyncData(confirmed);
      Error.throwWithStackTrace(error, stack);
    }
  }
}

final partiesProvider = AsyncNotifierProvider.family<PartiesController, PartiesSnapshot, String>(
  PartiesController.new,
);
