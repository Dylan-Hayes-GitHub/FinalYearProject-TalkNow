class Login {
  const Login._({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  Login(this.email, this.password);

  static Login fromJson(Map<String, dynamic> json) {
    return Login._(
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'Password': password,
    };
  }

  static Login fromDomain(Login domain) {
    return Login._(
      email: domain.email,
      password: domain.password,
    );
  }
}
