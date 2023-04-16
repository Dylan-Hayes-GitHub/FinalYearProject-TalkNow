using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using TalkTwoYou.Models.Configeration;
using TalkTwoYou.Models.JwtTokens.Validation;

namespace TalkTwoYou.Services.Authentication;

public class ValidateJwt : IValidateJWT
{
    private readonly IConfiguration _configuration;



    public ValidateJwt(IConfiguration configuration)
    {
        _configuration = configuration;
    }
    
    public bool ValidateToken(string token)
    {
        Jwt jwt = new Jwt(_configuration);
        TokenValidationParameters tokenValidationParameters = new TokenValidationParameters
        {
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Key)),
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwt.Issuer,
            ValidAudience = jwt.Audience,
            ClockSkew = TimeSpan.Zero
        };
        
        JwtSecurityTokenHandler jwtSecurityTokenHandler = new JwtSecurityTokenHandler();
        try
        {
            jwtSecurityTokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken validatedToken);
            return true;
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return false;
        }
    }

}