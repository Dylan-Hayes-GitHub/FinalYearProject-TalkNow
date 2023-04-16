using System.Security.Claims;
using TalkTwoYou.Models.DatabaseModels;
using TalkTwoYou.Models.JwtTokens.Interfaces;

namespace TalkTwoYou.Services.Authentication;

public class AccessTokenGenerator : IAccessToken
{
    private readonly ITokenGenerator _tokenGenerator;
    private readonly IConfiguration _configuration;

    public AccessTokenGenerator(ITokenGenerator tokenGenerator, IConfiguration configuration)
    {
        _tokenGenerator = tokenGenerator;
        _configuration = configuration;
    }

    public string GenerateToken(UserDetails newUser)
    {
        
        var claims = new[]
        {
            new Claim(ClaimTypes.Email, newUser.Email)
        };

        return _tokenGenerator.GenerateToken(_configuration["Jwt:Key"], _configuration["Jwt:Issuer"], _configuration["Jwt:Audience"] , 10,claims);
    }
    
}