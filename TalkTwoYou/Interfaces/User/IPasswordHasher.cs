namespace TalkTwoYou.Interfaces.User;

public interface IPasswordHasher
{
    public string HashPassword(string password);
    public bool VerifyPassword(string password, string base64Hash);
}