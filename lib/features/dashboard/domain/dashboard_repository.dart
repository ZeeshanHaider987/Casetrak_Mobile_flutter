import '../../matters/data/models/matter.dart';
import '../data/models/dashboard_data.dart';

abstract class DashboardRepository {
  Future<DashboardData> load(MatterAccessContext access);
}
