class UserModel {
  final String id;
  final String name;
  final String username;
  final String mobile;
  final String role;
  final bool isActive;
  final String token;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.mobile,
    required this.role,
    required this.isActive,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id:       json['id']       as String,
      name:     json['name']     as String,
      username: json['username'] as String,
      mobile:   json['mobile']   as String,
      role:     json['role']     as String,
      isActive: json['isActive'] as bool,
      token:    token,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':       id,
        'name':     name,
        'username': username,
        'mobile':   mobile,
        'role':     role,
        'isActive': isActive,
        'token':    token,
      };
}
