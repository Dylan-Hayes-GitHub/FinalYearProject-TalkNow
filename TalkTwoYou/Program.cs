using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SpaServices.AngularCli;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using TalkTwoYou.Data;
using TalkTwoYou.Helpers;
using TalkTwoYou.Interfaces;
using TalkTwoYou.Interfaces.Repos;
using TalkTwoYou.Interfaces.User;
using TalkTwoYou.Models.Configeration;
using TalkTwoYou.Models.JwtTokens;
using TalkTwoYou.Models.JwtTokens.Interfaces;
using TalkTwoYou.Models.JwtTokens.Validation;
using TalkTwoYou.Repos.UserDetailsRepo;
using TalkTwoYou.Repos.UserRefreshTokenRepo;
using TalkTwoYou.Services;
using TalkTwoYou.Services.Authentication;
using TalkTwoYou.Services.User;


var builder = WebApplication.CreateBuilder(args);


// Add services to the container.
builder.Services.AddDbContext<DataContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
});
//dependency injection for when classes are instantiated inside of web api controllers
builder.Services.AddScoped<IAccessToken, AccessTokenGenerator>();
builder.Services.AddScoped<IRefreshToken, RefreshTokenGenerator>();
builder.Services.AddScoped<ITokenGenerator, TokenGenerator>();
builder.Services.AddScoped<IValidateJWT, ValidateJwt>();
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<IEmailSender, EmailSender>();
builder.Services.AddScoped<IUserDetailsRepo, UserDetailsRepo>();
builder.Services.AddScoped<IUserRefreshTokenRepo, UserRefreshTokenRepo>();
builder.Services.AddControllersWithViews();
builder.Services.AddSpaStaticFiles(configuration =>
{
    configuration.RootPath = "ClientApp/dist";
});
builder.Services.AddCors(options =>
{
    options.AddPolicy("MyCorsPolicy", builder => builder.WithOrigins("*").AllowAnyHeader().AllowAnyMethod().AllowAnyOrigin());
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"])),
        ClockSkew = TimeSpan.Zero
    };
});
// builder.Services.AddScoped<>()
var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
}

app.UseStaticFiles();
app.UseRouting();
app.UseCors("MyCorsPolicy");
app.UseAuthentication();
app.UseAuthorization();
app.UseEndpoints(endpoints =>
{
    endpoints.MapControllerRoute(
        name: "default",
        pattern: "{controller}/{action=Index}/{id?}");
});
if (app.Environment.IsDevelopment())
{
    app.UseSpaStaticFiles();
}


app.UseSpa(spa =>
{
    // To learn more about options for serving an Angular SPA from ASP.NET Core,
    // see https://go.microsoft.com/fwlink/?linkid=864501

    spa.Options.SourcePath = "ClientApp";

    if (app.Environment.IsDevelopment())
    {
        //spa.UseAngularCliServer(npmScript: "start");
        spa.UseProxyToSpaDevelopmentServer("http://localhost:4200");
        //spa.UseProxyToSpaDevelopmentServer("*");
    }
});

app.Run();

