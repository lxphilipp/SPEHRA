/// Represents a user entity.
class UserEntity {
  /// The unique identifier of the user.
  final String id;

  /// The email address of the user.
  final String? email;

  /// The name of the user.
  final String? name;

  /// Creates a [UserEntity] instance.
  UserEntity({
    required this.id,
    this.email,
    this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.name == name;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode;

  /// Creates a copy of this user entity with the given fields replaced with the new values.
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}