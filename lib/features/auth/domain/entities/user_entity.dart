class UserEntity {
  final String? id;
  final String? email;
  final String? displayName;

  const UserEntity({
    this.id,
    this.email,
    this.displayName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ displayName.hashCode;
}
