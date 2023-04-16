using TalkTwoYou.Models.DatabaseModels;

namespace TalkTwoYou.Models.JwtTokens.Interfaces;

public interface IAccessToken
{
    public string GenerateToken(UserDetails newUser);
}