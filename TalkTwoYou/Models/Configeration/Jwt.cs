using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace TalkTwoYou.Models.Configeration;

public class Jwt
{
    private IConfiguration _configuration;
    public Jwt(IConfiguration configuration)
    {
        _configuration = configuration;
        Key = _configuration["Jwt:Key"];
        Audience = _configuration["Jwt:Audience"];
        Issuer = _configuration["Jwt:Issuer"];
        RefreshTokenKey = _configuration["Jwt:RefreshKey"];
    }

    public string Key { get; set; }
    public string RefreshTokenKey { get; set; }
    public string Audience { get; set; }
    public string Issuer { get; set; }


}