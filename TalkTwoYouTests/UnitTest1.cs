using System.Net;
using FluentAssertions;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Newtonsoft.Json;
using TalkTwoYou.Controllers;
using TalkTwoYou.DTO;
using TalkTwoYou.Interfaces.Repos;
using TalkTwoYou.Models.DatabaseModels;
using TalkTwoYou.Models.JwtTokens.Validation;
namespace TalkTwoYouTests;

public class UnitTest1
{
    [Fact]
    public async Task GetUserDetails_MatchedResult_AreEqual()
    {
        // Arrange
        var firebaseId = "dmrkSvkSD4VASOvcFQydXqVHWsf2";
        var userDetails = new UserDetails {UserId = Guid.NewGuid(), Email = "TEST", Password = "TTT", FirebaseUid = firebaseId, FirstName = "Dylan", LastName = "Hayes"};
        var json = JsonConvert.SerializeObject(userDetails, Formatting.Indented);

        var userDetailsRepoMock = new Mock<IUserDetailsRepo>();
        var refreshTokenRepo = new Mock<IUserRefreshTokenRepo>();
        var validateTokenRepo =  new Mock<IValidateJWT>();
        
        userDetailsRepoMock.Setup(repo => repo.GetUserDetailsByFireId(firebaseId)).ReturnsAsync(userDetails);

        var controller = new UserController(userDetailsRepoMock.Object, refreshTokenRepo.Object, validateTokenRepo.Object);

        // Act
        var result = await controller.GetUserDetails(firebaseId) as OkObjectResult;
       
        // Assert
        Assert.NotNull(result);
        Assert.Equal(200, result.StatusCode);
        Assert.Equal(json, result.Value);
    }

    [Fact]
    public async Task GetUserDetails_Results_UserDetails_NotFound()
    {
        // Arrange
        var userDetailsRepoMock = new Mock<IUserDetailsRepo>();
        var refreshTokenRepo = new Mock<IUserRefreshTokenRepo>();
        var validateTokenRepo =  new Mock<IValidateJWT>();
        
        userDetailsRepoMock.Setup(repo => repo.GetUserDetailsByFireId("wrongFireId")).ReturnsAsync((UserDetails)null);

        var controller = new UserController(userDetailsRepoMock.Object, refreshTokenRepo.Object, validateTokenRepo.Object);

        // Act
        var result = await controller.GetUserDetails("wrongFireId") as NotFoundObjectResult;
       
        // Assert
        var notFoundResult = Assert.IsType<NotFoundResult>(result);

        Assert.Equal(404 , notFoundResult?.StatusCode);
    }

    [Fact]
    public async Task Login_User_No_Details_Provided()
    {
        // Arrange
        var userDetailsRepoMock = new Mock<IUserDetailsRepo>();
        var refreshTokenRepo = new Mock<IUserRefreshTokenRepo>();
        var validateTokenRepo =  new Mock<IValidateJWT>();
        
        var controller = new UserController(userDetailsRepoMock.Object, refreshTokenRepo.Object, validateTokenRepo.Object);
        UserLoginDTO userLoginDto = new UserLoginDTO();
        
        //Act
        var result = await controller.Login(userLoginDto) as BadRequestObjectResult;
  
        // Assert
        Assert.NotNull(result);
        Assert.Equal(400, result.StatusCode);
    }

    [Fact]
    public async Task Login_User_IncorrectDetails_Provided()
    {
        //Arrange
        var userDetails = new UserLoginDTO();
        userDetails.Email = "not an email";
        userDetails.Password = "not a password";
        
        //mock repos
        var userDetailsRepoMock = new Mock<IUserDetailsRepo>();
        var refreshTokenRepo = new Mock<IUserRefreshTokenRepo>();
        var validateTokenRepo =  new Mock<IValidateJWT>();
        
        var controller = new UserController(userDetailsRepoMock.Object, refreshTokenRepo.Object, validateTokenRepo.Object);
        
        //mock get user details function
        userDetailsRepoMock.Setup(repo => repo.GetUser(userDetails.Email)).ReturnsAsync((UserDetails)null);
        
        // Act
        var result = await controller.Login(userDetails);
        
        // Assert
        var badRequestResult = Assert.IsType<BadRequestResult>(result);
        Assert.Equal(400, badRequestResult.StatusCode);
    }

    [Fact]
    public async Task Login_User_CorrectDetailsProvided_NotVerified()
    {
        //Arrange
        var userLoginDto = new UserLoginDTO();
        userLoginDto.Email = "not an email";
        userLoginDto.Password = "not a password";

        var userDetails = new UserDetails();
        userDetails.Email = "not an email";
        userDetails.Password = "not a password";
        userDetails.FirebaseUid = "not a firebase id";
        userDetails.FirstName = "Dylan";
        userDetails.LastName = "Hayes";
        userDetails.UserId = new Guid();

        var registerStatus = new RegisterStatus();
        registerStatus.Verified = false;
        registerStatus.EmailCode = 123;
        registerStatus.UserId = userDetails.UserId;
        registerStatus.FullyRegistered = new Guid();

        //mock repos
        var userDetailsRepoMock = new Mock<IUserDetailsRepo>();
        var refreshTokenRepo = new Mock<IUserRefreshTokenRepo>();
        var validateTokenRepo =  new Mock<IValidateJWT>();
        
        var controller = new UserController(userDetailsRepoMock.Object, refreshTokenRepo.Object, validateTokenRepo.Object);
        
        userDetailsRepoMock.Setup(repo => repo.GetUser(userLoginDto.Email)).ReturnsAsync(userDetails);
        userDetailsRepoMock.Setup(repo => repo.IsUserVerifiedAlready(userDetails.UserId)).ReturnsAsync(registerStatus);

        var result = await controller.Login(userLoginDto) as UnauthorizedObjectResult;

        Assert.IsType<UnauthorizedObjectResult>(result);
        Assert.Equal(401, result.StatusCode);
    }
    


    }

