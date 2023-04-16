class UserDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String oldPassword;
  final String newPassword;
  const UserDetails._({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.oldPassword,
    required this.newPassword,
  });

  UserDetails(this.firstName, this.lastName, this.email, this.oldPassword,
      this.newPassword);

  static UserDetails fromJson(Map<String, dynamic> json) {
    return UserDetails._(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      oldPassword: json['oldPassword'],
      newPassword: json['newPassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }

  static UserDetails fromDomain(UserDetails domain) {
    return UserDetails._(
      firstName: domain.firstName,
      lastName: domain.lastName,
      email: domain.email,
      oldPassword: domain.oldPassword,
      newPassword: domain.newPassword,
    );
  }
}
