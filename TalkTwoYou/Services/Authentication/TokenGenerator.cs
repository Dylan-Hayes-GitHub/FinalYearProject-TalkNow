using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using TalkTwoYou.Models.JwtTokens.Interfaces;

namespace TalkTwoYou.Services.Authentication;

public class TokenGenerator : ITokenGenerator
{
    public string GenerateToken(string key, string issuer, string audience, int duration = 10, IEnumerable<Claim>? claims = null) {
        var secureKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
        var credentials = new SigningCredentials(secureKey, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(issuer,
            audience: audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: DateTime.Now.AddMonths(duration),
            signingCredentials: credentials);
        return new JwtSecurityTokenHandler().WriteToken(token);
        
    }
}