import '../../../core/models/paged.dart';
import '../data/models/matter.dart';
import '../data/models/matter_detail.dart';

abstract class MatterRepository {
  Future<Paged<Matter>> list(MatterQuery query, MatterAccessContext access);

  Future<MatterDetail> getById(String id, MatterAccessContext access);

  Future<List<Matter>> forClient(String clientId, MatterAccessContext access);
}
