namespace TalkTwoYou.Models.JwtTokens.Interfaces;

public interface IRefreshToken
{
    public string GenerateToken();
}