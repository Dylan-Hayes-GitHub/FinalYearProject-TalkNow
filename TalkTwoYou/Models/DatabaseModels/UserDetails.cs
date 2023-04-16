using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;
using Microsoft.EntityFrameworkCore;

namespace TalkTwoYou.Models.DatabaseModels;

public class UserDetails
{
    [Key]
    public Guid UserId { get; set; }

    [Column(TypeName = "varchar(200)")]
    public string FirstName { get; set; } = string.Empty;

    [Column(TypeName = "varchar(200)")]
    public string LastName { get; set; } = string.Empty;

    [Column(TypeName = "varchar(200)")]
    public string Email { get; set; } = string.Empty;
    
    public string Password { get; set; } = string.Empty;
    public string FirebaseUid { get; set; } = string.Empty;
}