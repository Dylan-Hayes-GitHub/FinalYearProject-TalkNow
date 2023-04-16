using System.Net;
using System.Net.Mail;
using TalkTwoYou.Interfaces;

namespace TalkTwoYou.Services.User;

public class EmailSender : IEmailSender
{

    private static string _fromAddress = "talknowire@gmail.com";
    private static string _password = "vjmnntpihucdfrcz";
    
    public void SendEmail(string userEmail, int verificationCode, Guid uniqueId)
    {

        string url = "http://localhost:4200/thankyou/";

        string finalUrl = $"{url}?verificationcode={verificationCode}&id={uniqueId}";
        
        //create instance of smtp sender
        MailMessage email = new MailMessage();

        email.From = new MailAddress(_fromAddress);
        email.Subject = "Email verification";
        email.To.Add(new MailAddress(userEmail));
        email.Body = $"Hi, Thank you for registering to talk now. <br> " +
                     $"You must verify for your email before you can use the application. This can be done by navigation to the " +
                     $"provided link. <br><a href='{finalUrl}'>Verify Link</a>" ;
        email.IsBodyHtml = true;

        var smtpClient = new SmtpClient("smtp.gmail.com")
        {
            Port = 587,
            Credentials = new NetworkCredential(_fromAddress, _password),
            EnableSsl = true
        };
        
        smtpClient.Send(email);
        
    }
}