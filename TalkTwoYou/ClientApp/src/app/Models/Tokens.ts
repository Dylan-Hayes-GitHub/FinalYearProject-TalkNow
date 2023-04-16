export interface LoginDao  {
    refreshToken: string;
    jwtToken: string;
    username: string;
}

export interface RefreshToken {
  RefreshTokenToValidate: string;
}

export interface Jwt {
  jwtToken: string;
}
