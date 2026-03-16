import 'package:uuid/uuid.dart';
import '../../../shared/models/client.dart';
import '../../../repositories/client_repository.dart';

class ClientSeeder {
  final ClientRepository _clientRepository;

  ClientSeeder(this._clientRepository);

  Future<void> seed() async {
    if (_clientRepository.getAll().isNotEmpty) return;

    final List<Client> initialClients = [
      Client(
        id: const Uuid().v4(),
        name: "Moussa le Boutiquier",
        phone: "+237 677 888 999",
        address: "Marché Central, Yaoundé",
        createdAt: DateTime.now(),
      ),
      Client(
        id: const Uuid().v4(),
        name: "Épicerie la Paix",
        phone: "+237 699 000 111",
        address: "Bonanjo, Douala",
        createdAt: DateTime.now(),
      ),
      Client(
        id: const Uuid().v4(),
        name: "Maman Marie",
        phone: "+237 655 444 333",
        address: "Akwa, Douala",
        createdAt: DateTime.now(),
      ),
    ];

    for (var client in initialClients) {
      await _clientRepository.add(client.id, client);
    }
  }
}
