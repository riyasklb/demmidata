import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  

}
