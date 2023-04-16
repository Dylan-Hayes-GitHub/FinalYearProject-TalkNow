using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using TalkTwoYou.DAO;
using TalkTwoYou.Data;
using TalkTwoYou.DTO;
using TalkTwoYou.Interfaces.Repos;
using TalkTwoYou.Models.DatabaseModels;
using TalkTwoYou.Models.JwtTokens.Validation;

namespace TalkTwoYou.Controllers
{
    [Route("api/[controller]")]
    [EnableCors("MyCorsPolicy")]
    [ApiController]
    public class UserController : ControllerBase
    {

        private readonly IUserDetailsRepo _userDetailsRepo;
        private readonly IUserRefreshTokenRepo _userRefreshTokenRepo;
        private readonly IValidateJWT _validateJwt;
        
        // POST: api/User
        public UserController(IUserDetailsRepo userDetailsRepo, IUserRefreshTokenRepo userRefreshTokenRepo, IValidateJWT validateJwt)
        {
            _userDetailsRepo = userDetailsRepo;
            _userRefreshTokenRepo = userRefreshTokenRepo;
            _validateJwt = validateJwt;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] UserLoginDTO? userLoginDto)
        {
            if (userLoginDto.Email == null)
            {
                return NotFound("User not found");
            }

            if (userLoginDto.Email.Equals("") || userLoginDto.Password.Equals(""))
            {
                return NotFound("Email or password not provided");
            }

            var userDetailsInDb = await _userDetailsRepo.GetUser(userLoginDto.Email);
            //verify the user has verified their email before they can login

            if (userDetailsInDb == null)
            {
                return NotFound();
            }
            
            var userRegisterStatus = await _userDetailsRepo.IsUserVerifiedAlready(userDetailsInDb.UserId);

            if (!userRegisterStatus.Verified)
            {
                return Unauthorized("User is not verified");
            }

            var tokensToSendToUser = await _userDetailsRepo.Login(userLoginDto, userDetailsInDb);
            
            //save refresh token to db
            
            await _userRefreshTokenRepo.SaveRefreshToken(tokensToSendToUser.RefreshToken, userDetailsInDb.UserId);
            
            //return ok response with tokens
            return Ok(tokensToSendToUser);
        }
        

        // PUT: api/User/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutUserDetails(int id, UserDetails userDetails)
        {

            if (userDetails == null)
            {
                return BadRequest();
            }
            
            await _userDetailsRepo.Register(userDetails);

            return Ok();
        }

        // DELETE: api/User/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }

        [HttpGet("verify")]
        public async Task<IActionResult> VerifyUser([FromQuery(Name = "verificationcode")] int verificationCode, [FromQuery(Name = "id")] Guid uniqueId)
        {
            
            //first check and see if the verification code and id exist
            if (verificationCode == null || uniqueId == null)
            {
                return BadRequest("Invalid verification link");
            }
            
            //update verification status
            var res = await _userDetailsRepo.verifyUser(verificationCode, uniqueId);

            return Ok(res);
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> RefreshUser([FromBody] RefreshToken userRefreshToken)
        {
            string refreshToken = userRefreshToken.RefreshTokenToValidate;
            bool shouldGenerateNewTokens = await _userRefreshTokenRepo.ValidRefresh(refreshToken);

            if (shouldGenerateNewTokens)
            {
                var usersTokens = await _userRefreshTokenRepo.GenerateNewTokens(userRefreshToken);
                
                return Ok(usersTokens);
            }

            return Unauthorized();
        }

        [HttpPost("validUser")]
        public async Task<IActionResult> ValidateJwt([FromBody] Jwt jwt)
        {
            bool res = _validateJwt.ValidateToken(jwt.JwtToken);

            return Ok(res);
        }

        /*[HttpPost("getUserInfo")]
        public async Task<IActionResult> GetUserDetails([FromBody] RefreshToken userRefreshToken)
        {
            
        }*/
        
        [Authorize]
        [HttpGet("GetUserDetails")]
        public async Task<IActionResult> GetUserDetails(string? firebaseId){
            if (firebaseId == null)
            {
                return BadRequest();
            }

            var userDetails = await _userDetailsRepo.GetUserDetailsByFireId(firebaseId);
            if (userDetails == null)
            {
                return NotFound();
            }
            var json = JsonConvert.SerializeObject(userDetails, formatting: Formatting.Indented);
            return Ok(json);
        }
    
        [HttpPost("updateUserDetails")]
        public async Task<IActionResult> UpdateUserDetails([FromBody] UserDetailsDao userDetailsDao)
        {
            if (userDetailsDao == null)
            {
                return BadRequest("User is undefined");
            }

            bool res = await _userDetailsRepo.UpdateUserDetails(userDetailsDao);

            if (!res)
            {
                return BadRequest("Update failed");
            }

            return Ok();
        }

        [HttpPost("isUserFullyVerified")]
        public async Task<IActionResult> verifyUserStatus([FromBody] UserVerificationDao userVerificationDao)
        {
            if (userVerificationDao.FirebaseId.IsNullOrEmpty())
            {
                return BadRequest();
            }

            bool res = await _userDetailsRepo.isUserEmailVerified(userVerificationDao);
            
            return Ok(res);
        }

        [HttpGet("verifyUserByFireId")]
        public async Task<IActionResult> GetUserId(string firebaseId)
        {
            bool userVerified = await _userDetailsRepo.GetUserGuidFromFirebaseId(firebaseId);
            if (userVerified)
            {
                return Ok();
            }

            return Unauthorized();
            
        }

    }
}
