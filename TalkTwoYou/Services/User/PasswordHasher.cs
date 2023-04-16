using System.Security.Cryptography;
using TalkTwoYou.Interfaces;
using TalkTwoYou.Interfaces.User;

namespace TalkTwoYou.Services.User;

public class PasswordHasher : IPasswordHasher
{
    private static RandomNumberGenerator _rng = RandomNumberGenerator.Create();

    private const int SaltSize = 16;
    private const int HashSize = 20;
    private const int Iterations = 1000;


    public string HashPassword(string password)
    {
        byte[] salt;
        _rng.GetBytes(salt = new Byte[SaltSize]);

        var key = new Rfc2898DeriveBytes(password, salt, Iterations);
        var hash = key.GetBytes(HashSize);

        var hashBytes = new byte[SaltSize + HashSize];
        Array.Copy(salt, 0, hashBytes, 0, SaltSize);
        Array.Copy(hash, 0, hashBytes, SaltSize, HashSize);

        var base64Hash = Convert.ToBase64String(hashBytes);

        return base64Hash;
    }

    public bool VerifyPassword(string password, string base64Hash)
    {
        var hashBytes = Convert.FromBase64String(base64Hash);

        var salt = new byte[SaltSize];
        Array.Copy(hashBytes, 0, salt, 0, SaltSize);

        var key = new Rfc2898DeriveBytes(password, salt, Iterations);
        byte[] hash = key.GetBytes(HashSize);

        for (int i = 0; i < HashSize; i++)
        {
            if (hashBytes[i + SaltSize] != hash[i])
            {
                return false;
            }
        }
        return true;
    }
}