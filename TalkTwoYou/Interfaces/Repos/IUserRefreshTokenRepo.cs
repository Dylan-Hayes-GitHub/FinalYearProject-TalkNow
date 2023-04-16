using Microsoft.AspNetCore.Mvc;
using TalkTwoYou.DTO;
using TalkTwoYou.Models;
using TalkTwoYou.Models.DatabaseModels;

namespace TalkTwoYou.Interfaces.Repos;

public interface IUserRefreshTokenRepo
{
    public Task SaveRefreshToken(string refreshToken, Guid userId);
    public Task<bool> ValidRefresh(string refreshToken);
    public Task<Tokens> GenerateNewTokens(RefreshToken refreshToken);

}