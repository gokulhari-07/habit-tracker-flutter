class UserEntity {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
  });
}