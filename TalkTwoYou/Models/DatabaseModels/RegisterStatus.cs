using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.Build.Framework;
using Microsoft.EntityFrameworkCore;
using TalkTwoYou.DTO;

namespace TalkTwoYou.Models.DatabaseModels;

public class RegisterStatus
{
    [Key]
    public Guid FullyRegistered { get; set; }
    
    public Guid UserId { get; set; }
    
    public int EmailCode { get; set; }
    
    public bool Verified { get; set; }
}
