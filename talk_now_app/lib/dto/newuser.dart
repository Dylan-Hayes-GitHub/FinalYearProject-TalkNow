class NewUser {
  const NewUser._({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.firebaseUid,
  });
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String firebaseUid;

  const NewUser(this.firstName, this.lastName, this.email, this.password,
      this.firebaseUid);

  static NewUser fromJson(Map<String, dynamic> json) {
    return NewUser._(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      firebaseUid: json['firebaseUid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'firebaseUid': firebaseUid,
    };
  }

  static NewUser fromDomain(NewUser domain) {
    return NewUser._(
      firstName: domain.firstName,
      lastName: domain.lastName,
      email: domain.email,
      password: domain.password,
      firebaseUid: domain.firebaseUid,
    );
  }
}
