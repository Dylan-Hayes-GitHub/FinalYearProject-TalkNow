
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using NuGet.Protocol;
using TalkTwoYou.DAO;
using TalkTwoYou.Data;
using TalkTwoYou.DTO;
using TalkTwoYou.Interfaces;
using TalkTwoYou.Interfaces.Repos;
using TalkTwoYou.Interfaces.User;
using TalkTwoYou.Models;
using TalkTwoYou.Models.DatabaseModels;
using TalkTwoYou.Models.JwtTokens.Interfaces;

namespace TalkTwoYou.Repos.UserDetailsRepo;

public class UserDetailsRepo : IUserDetailsRepo
{
    private readonly DataContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IRefreshToken _refreshToken;
    private readonly IAccessToken _accessToken;
    private readonly IEmailSender _emailSender;

    public UserDetailsRepo(DataContext dataContext, IPasswordHasher passwordHasher, IRefreshToken refreshToken, IAccessToken accessToken, IEmailSender emailSender)
    {
        _context = dataContext;
        _passwordHasher = passwordHasher;
        _refreshToken = refreshToken;
        _accessToken = accessToken;
        _emailSender = emailSender;
    }

    public async Task<Tokens> Login(UserLoginDTO userDetailsLoginDto, UserDetails userInDb)
    {
        //use password hasher to confirm they are the same person
        if (_passwordHasher.VerifyPassword(userDetailsLoginDto.Password, userInDb.Password))
        {
            //create JWT token, refresh token and return
            var token = _accessToken.GenerateToken(userInDb);
            var refreshToken = _refreshToken.GenerateToken();


            //await _context.RefreshToken.AddAsync(refreshTokenDto);
            // _context.SaveChangesAsync();
            return new Tokens
            {
                RefreshToken = refreshToken,
                JwtToken = token,
                Username = userInDb.FirstName
            };
        }
        return null;
    }

    public async Task Register(UserDetails userDetails)
    {
        userDetails.UserId = Guid.NewGuid();
        //hash user password
        var hashedPassword = _passwordHasher.HashPassword(userDetails.Password);
        userDetails.Password = hashedPassword;

        //generate random 4 digit code
        Random random = new Random();
        int randomNumber = random.Next(1, 1001);
        
        //save new user 
        await _context.UserDetails.AddAsync(userDetails);
        await _context.SaveChangesAsync();

        //create new instance of Register status DTO to store in register status db for verification
        RegisterStatus? registerStatusDto = new RegisterStatus();
        registerStatusDto.FullyRegistered = Guid.NewGuid();
        registerStatusDto.UserId = userDetails.UserId;
        registerStatusDto.EmailCode = randomNumber;
        registerStatusDto.Verified = false;
        //save new verification status
        await _context.RegisterStatus.AddAsync(registerStatusDto);

        //send email
        _emailSender.SendEmail(userDetails.Email, randomNumber, registerStatusDto.FullyRegistered);
        await _context.SaveChangesAsync();

    }

    public async void VerifyUser(int verificationCode, Guid uniqueId)
    {
        try
        {
            var userToVerify =  _context.RegisterStatus.FirstOrDefault(x => x.EmailCode == verificationCode && x.FullyRegistered == uniqueId);
            if (userToVerify != null)
            {

                userToVerify.Verified = true;
                 _context.SaveChanges();
            }
        }
        catch (Exception e)
        {
            throw;
        }

    }

    public async Task<RegisterStatus?> IsUserVerifiedAlready(Guid userId)
    {
        return await _context.RegisterStatus.FirstOrDefaultAsync(x => x.UserId == userId);
    }

    public async Task<UserDetails> GetUserDetailsByFireId(string firebaseId)
    {
        UserDetails? userDetails = await _context.UserDetails.FirstOrDefaultAsync(x => x.FirebaseUid == firebaseId);

        return userDetails;
    }

    public async Task<bool> UpdateUserDetails(UserDetailsDao userDetailsDao)
    {


        UserDetails userToUpdate = await _context.UserDetails.FirstOrDefaultAsync(x => x.Email == userDetailsDao.email);

        if (userToUpdate == null)
        {
            return false;
        }
        if (userDetailsDao.oldPassword.IsNullOrEmpty())
        {
            //regular user update with change of password
            userToUpdate.Email = userDetailsDao.email;
            userToUpdate.FirstName = userDetailsDao.firstName;
            userToUpdate.LastName = userDetailsDao.lastName;
            await _context.SaveChangesAsync();
            return true;
        }

        if (userDetailsDao.newPassword.IsNullOrEmpty())
        {

            return false;
        }

        //assume that if we are this far that the user has entered a new password for updating
        //first need to check if the old password is what already exists in the db for updating
        if (_passwordHasher.VerifyPassword(userDetailsDao.oldPassword, userToUpdate.Password))
        {
            //valid for updating
            userToUpdate.Email = userDetailsDao.email;
            userToUpdate.FirstName = userDetailsDao.firstName;
            userToUpdate.LastName = userDetailsDao.lastName;

            //need to has new password
            var newPassword = _passwordHasher.HashPassword(userDetailsDao.newPassword);
            userToUpdate.Password = newPassword;

            await _context.SaveChangesAsync();

            return true;
        }
        
        return false;


    }

    public async Task<bool> isUserEmailVerified(UserVerificationDao userVerificationDao)
    {
        var user = await _context.UserDetails.FirstOrDefaultAsync(x => x.FirebaseUid == userVerificationDao.FirebaseId);
        if (user == null)
        {

            return false;
        }

        var userRegisterStatus = await _context.RegisterStatus.FirstOrDefaultAsync(x => x.UserId == user.UserId);

        if (userRegisterStatus == null)
        {
            return false;
        }
        
        return userRegisterStatus.Verified;
    }

    public async Task<bool> verifyUser(int verificationCode, Guid userId)
    {
        var registerStatus = await _context.RegisterStatus.FirstOrDefaultAsync(x => x.FullyRegistered == userId && x.EmailCode == verificationCode);

        if (registerStatus == null)
        {
            return false;
        }

        registerStatus.Verified = true;
        await _context.SaveChangesAsync();
        return true;


    }

    public async Task<bool> GetUserGuidFromFirebaseId(string firebaseId)
    {
        var user = await _context.UserDetails.FirstOrDefaultAsync(x => x.FirebaseUid == firebaseId);
        
        //verify if the user is verified
        var userVerified = await _context.RegisterStatus.FirstOrDefaultAsync(x => x.UserId == user.UserId);
        return userVerified.Verified ? true : false;
    }

    public async Task<Tokens> GenerateNewTokens(RefreshToken refreshToken)
    {
        var user = await _context.UserRefreshTokens.FirstOrDefaultAsync(x =>  x.RefreshToken == refreshToken.RefreshTokenToValidate);

        var userDetails = await _context.UserDetails.FirstOrDefaultAsync(x => user != null && x.UserId == user.UserId);
        
        var token = _accessToken.GenerateToken(userDetails);
        var newRefreshToken = _refreshToken.GenerateToken();


        return new Tokens
        {
            RefreshToken = newRefreshToken,
            JwtToken = token,
            Username = userDetails.FirstName
        };
    }

    public async Task<UserDetails> GetUser(string email)
    {
        return await _context.UserDetails.FirstOrDefaultAsync(u => u.Email.Equals(email));
    }

    public async Task<RegisterStatus?> VerifyVerificationLink(int verificationCode, Guid uniqueId)
    {
        return await _context.RegisterStatus.FirstOrDefaultAsync(x => x.FullyRegistered == uniqueId
                                                                      && x.EmailCode == verificationCode);
    }


}