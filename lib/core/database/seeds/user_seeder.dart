import 'package:uuid/uuid.dart';
import '../../../shared/models/user.dart';
import '../../../repositories/user_repository.dart';

class UserSeeder {
  final UserRepository _userRepository;

  UserSeeder(this._userRepository);

  Future<void> seed() async {
    // On ne peuple que si la base est vide
    if (_userRepository.getAll().isNotEmpty) return;

    final List<User> initialUsers = [
      User(
        id: const Uuid().v4(),
        name: "Administrateur",
        phone: "+237 600 000 000",
        email: "admin@gestock.cm",
        password: "admin", // Mot de passe par défaut pour le test
        createdAt: DateTime.now(),
      ),
      User(
        id: const Uuid().v4(),
        name: "Gestionnaire",
        phone: "+237 611 111 111",
        email: "manager@gestock.cm",
        password: "password",
        createdAt: DateTime.now(),
      ),
    ];

    for (var user in initialUsers) {
      await _userRepository.add(user.id, user);
    }
  }
}
