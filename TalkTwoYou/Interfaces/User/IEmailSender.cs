namespace TalkTwoYou.Interfaces;

public interface IEmailSender
{
    public void SendEmail(string userEmail, int verificationCode, Guid uniqueId);
}