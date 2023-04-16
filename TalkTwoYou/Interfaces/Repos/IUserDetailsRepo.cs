using Microsoft.AspNetCore.Mvc;
using TalkTwoYou.DAO;
using TalkTwoYou.DTO;
using TalkTwoYou.Models;
using TalkTwoYou.Models.DatabaseModels;

namespace TalkTwoYou.Interfaces.Repos;

public interface IUserDetailsRepo
{
    public Task<Tokens> Login(UserLoginDTO userDetailsLoginDto, UserDetails password);
    public Task Register(UserDetails userDetails);
    public Task<UserDetails> GetUser(string email);
    public Task<RegisterStatus?> VerifyVerificationLink(int verificationCode, Guid uniqueId);
    public void VerifyUser(int verificationCode, Guid uniqueId);
    public Task<RegisterStatus?> IsUserVerifiedAlready(Guid userId);
    public Task<UserDetails> GetUserDetailsByFireId(string firebaseId);
    public  Task<bool> UpdateUserDetails(UserDetailsDao userDetailsDao);
    public Task<bool> isUserEmailVerified(UserVerificationDao userVerificationDao);
    public Task<bool> verifyUser(int verificationCode, Guid userId);
    public Task<bool> GetUserGuidFromFirebaseId(string firebaseId);
    
}