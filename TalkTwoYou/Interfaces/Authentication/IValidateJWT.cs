namespace TalkTwoYou.Models.JwtTokens.Validation;

public interface IValidateJWT
{
    public bool ValidateToken(string token);
}