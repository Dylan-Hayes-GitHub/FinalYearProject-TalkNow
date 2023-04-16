using Microsoft.EntityFrameworkCore;
using TalkTwoYou.Models.DatabaseModels;

namespace TalkTwoYou.Data;

public class DataContext : DbContext
{
    public DataContext(DbContextOptions<DataContext>options) : base(options)
    {
    }

    public DbSet<UserDetails> UserDetails { get; set; }
     public DbSet<UserRefreshTokens> UserRefreshTokens { get; set; }
    public DbSet<RegisterStatus> RegisterStatus { get; set; }
    
   
}

