using TalkTwoYou.Models.JwtTokens.Interfaces;

namespace TalkTwoYou.Services.Authentication;

public class RefreshTokenGenerator : IRefreshToken
{
    private readonly ITokenGenerator _tokenGenerator;
    private readonly IConfiguration _configuration;

    public RefreshTokenGenerator(ITokenGenerator tokenGenerator, IConfiguration configuration)
    {
        _tokenGenerator = tokenGenerator;
        _configuration = configuration;
    }


    public string GenerateToken()
    {
      
        //add configeration here for refresh token secret plus new fresh time
        return _tokenGenerator.GenerateToken(_configuration["Jwt:Key"], _configuration["Jwt:Issuer"], _configuration["Jwt:Audience"], 86400);
    }
}