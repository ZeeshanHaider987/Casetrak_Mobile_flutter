import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../matters/data/models/matter.dart';
import '../domain/dashboard_repository.dart';
import 'models/dashboard_data.dart';

class RemoteDashboardRepo implements DashboardRepository {
  RemoteDashboardRepo(this._dio);

  final Dio _dio;

  @override
  Future<DashboardData> load(MatterAccessContext access) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>('/dashboard');
      final body = response.data ?? const <String, dynamic>{};
      final data = body['data'] is Map<String, dynamic> ? body['data'] as Map<String, dynamic> : body;
      return DashboardData(
        kpis: _kpis(data['kpis']),
        deadlines: _deadlines(data['deadlines']),
        activity: _activity(data['activity']),
      );
    });
  }

  List<DashboardKpi> _kpis(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map>())
        DashboardKpi(
          label: item['label']?.toString() ?? '',
          value: item['value']?.toString() ?? '',
          footnote: item['footnote']?.toString(),
        ),
    ];
  }

  List<DashboardDeadline> _deadlines(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map>())
        DashboardDeadline(
          id: item['id']?.toString() ?? '',
          matterId: item['matterId']?.toString() ?? '',
          title: item['title']?.toString() ?? '',
          dueOn: DateTime.tryParse(item['dueOn']?.toString() ?? '') ?? DateTime.now(),
        ),
    ];
  }

  List<DashboardActivity> _activity(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map>())
        DashboardActivity(
          id: item['id']?.toString() ?? '',
          matterId: item['matterId']?.toString() ?? '',
          title: item['title']?.toString() ?? '',
          detail: item['detail']?.toString() ?? '',
          at: DateTime.tryParse(item['at']?.toString() ?? '') ?? DateTime.now(),
        ),
    ];
  }
}
