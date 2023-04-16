using System.Security.Claims;

namespace TalkTwoYou.Models.JwtTokens.Interfaces;

public interface ITokenGenerator
{
    public string GenerateToken(string key, string issuer, string audience, int duration = 15, IEnumerable<Claim>? claims = null);
}