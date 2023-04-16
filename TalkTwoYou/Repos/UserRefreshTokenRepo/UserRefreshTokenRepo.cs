using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TalkTwoYou.Data;
using TalkTwoYou.DTO;
using TalkTwoYou.Interfaces.Repos;
using TalkTwoYou.Models;
using TalkTwoYou.Models.DatabaseModels;
using TalkTwoYou.Models.JwtTokens.Interfaces;

namespace TalkTwoYou.Repos.UserRefreshTokenRepo;

public class UserRefreshTokenRepo : IUserRefreshTokenRepo
{

    private readonly DataContext _dataContext;
    private readonly IAccessToken _accessToken;
    private readonly IRefreshToken _refreshToken;

    public UserRefreshTokenRepo(DataContext dataContext, IAccessToken accessToken, IRefreshToken refreshToken)
    {
        _dataContext = dataContext;
        _accessToken = accessToken;
        _refreshToken = refreshToken;
    }

    public async Task<bool> ValidRefresh(string refreshToken)
    {
        var res = await _dataContext.UserRefreshTokens.FirstOrDefaultAsync(x => x.RefreshToken == refreshToken);
        return res != null;
    }

    public async Task SaveRefreshToken(string refreshToken, Guid userId)
    {
        UserRefreshTokens userRefreshTokens = new UserRefreshTokens();
        userRefreshTokens.RefreshId = Guid.NewGuid();
        userRefreshTokens.RefreshToken = refreshToken;
        userRefreshTokens.UserId = userId;
        await _dataContext.UserRefreshTokens.AddAsync(userRefreshTokens);
        await _dataContext.SaveChangesAsync();
    }
    
    public async Task<Tokens> GenerateNewTokens(RefreshToken refreshToken)
    {
        var user = await _dataContext.UserRefreshTokens.FirstOrDefaultAsync(x =>  x.RefreshToken == refreshToken.RefreshTokenToValidate);

        var userDetails = await _dataContext.UserDetails.FirstOrDefaultAsync(x => user != null && x.UserId == user.UserId);
        
        var token = _accessToken.GenerateToken(userDetails);
        var newRefreshToken = _refreshToken.GenerateToken();

        await SaveRefreshToken(newRefreshToken, userDetails.UserId);

        return new Tokens
        {
            RefreshToken = newRefreshToken,
            JwtToken = token,
            Username = userDetails.FirstName
        };
    }
}