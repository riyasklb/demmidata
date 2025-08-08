import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.email,
    super.displayName,
  });

  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      id: user?.uid,
      email: user?.email,
      displayName: user?.displayName,
    );
  }
}
