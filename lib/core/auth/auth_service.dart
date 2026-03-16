import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user.dart' as model;
import '../../repositories/user_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  
  final UserRepository _userRepository;
  model.User? _currentUser;
  static const String _userKey = 'logged_in_user_id';

  AuthService(this._userRepository);

  model.User? get currentUser => _currentUser;

  bool get _isFirebaseAvailable {
    try {
      firebase_auth.FirebaseAuth.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<model.User?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final String uid = const Uuid().v4();
    model.User newUser = model.User(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      password: password, 
      createdAt: DateTime.now(),
    );

    if (_isFirebaseAvailable) {
      try {
        firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (result.user != null) {
          newUser.id = result.user!.uid;
          await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());
        }
      } catch (e) {
        debugPrint("Firebase Register échec: $e");
      }
    }

    await _userRepository.add(newUser.id, newUser);
    await _saveSession(newUser.id);
    _currentUser = newUser;
    return newUser;
  }

  Future<model.User?> login(String email, String password) async {
    final users = _userRepository.getAll();
    try {
      final localUser = users.firstWhere((u) => u.email == email && u.password == password);
      await _saveSession(localUser.id);
      _currentUser = localUser;
      return localUser;
    } catch (_) {}

    if (_isFirebaseAvailable) {
      try {
        firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (result.user != null) {
          DocumentSnapshot doc = await _firestore.collection('users').doc(result.user!.uid).get();
          if (doc.exists) {
            model.User user = model.User.fromMap(doc.data() as Map<String, dynamic>);
            await _userRepository.add(user.id, user);
            await _saveSession(user.id);
            _currentUser = user;
            return user;
          }
        }
      } catch (e) {
        debugPrint("Firebase Login échec: $e");
      }
    }
    return null;
  }

  Future<void> updateUser(model.User user) async {
    await _userRepository.update(user.id, user);
    _currentUser = user;
    if (_isFirebaseAvailable) {
      try {
        firebase_auth.User? fbUser = _auth.currentUser;
        if (fbUser != null && fbUser.uid == user.id) {
          await _firestore.collection('users').doc(user.id).update(user.toMap());
        }
      } catch (_) {}
    }
  }

  Future<model.User?> checkAuthState() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userKey);

    if (userId != null) {
      _currentUser = _userRepository.get(userId);
      if (_currentUser != null) return _currentUser;
    }

    if (_isFirebaseAvailable) {
      try {
        firebase_auth.User? fbUser = _auth.currentUser;
        if (fbUser != null) {
          _currentUser = _userRepository.get(fbUser.uid);
          if (_currentUser != null) {
            await _saveSession(_currentUser!.id);
            return _currentUser;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userId);
  }

  Future<void> logout() async {
    if (_isFirebaseAvailable) {
      try { await _auth.signOut(); } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
  }
}
