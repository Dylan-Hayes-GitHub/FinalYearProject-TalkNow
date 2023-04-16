class RefreshTokenRequest {
  String refreshTokenToValidate;

  RefreshTokenRequest({required this.refreshTokenToValidate});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['refreshTokenToValidate'] = refreshTokenToValidate;
    return data;
  }
}
