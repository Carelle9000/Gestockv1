import '../../shared/models/need.dart';
import '../../repositories/need_repository.dart';

class NeedService {
  final NeedRepository _needRepository;

  NeedService(this._needRepository);

  List<Need> getAllNeeds() {
    return _needRepository.getAll();
  }

  Future<void> addNeed(Need need) async {
    await _needRepository.add(need.id, need);
  }

  Future<void> updateNeed(String key, Need need) async {
    await _needRepository.update(key, need);
  }

  Future<void> deleteNeed(String key) async {
    await _needRepository.delete(key);
  }
}
