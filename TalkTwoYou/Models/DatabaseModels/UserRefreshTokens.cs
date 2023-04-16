using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace TalkTwoYou.Models.DatabaseModels;

[PrimaryKey(nameof(RefreshId))]
public class UserRefreshTokens
{
    public Guid RefreshId { get; set; }

    [ForeignKey("UserDetails")]
    public Guid UserId { get; set; }
    
    public string RefreshToken { get; set; }
}