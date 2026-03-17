class User {
  final int    id;
  final String username;
  final String gender;
  final String phone;
  final String email;
  final String photoName;

  User({
    required this.id,
    required this.username,
    required this.gender,
    required this.phone,
    required this.email,
    required this.photoName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id       : json['id']         as int,
      username : json['username']   as String? ?? '',
      gender   : json['gender']     as String? ?? '',
      phone    : json['phone']      as String? ?? '',
      email    : json['email']      as String? ?? '',
      photoName: json['photo_name'] as String? ?? '',
    );
  }
}