namespace TalkTwoYou.DTO;

public class RegisterStatusDTO
{
    public Guid FullyRegistered { get; set; }
    public Guid UserId { get; set; }
    public int EmailCode { get; set; }
    public bool Verified { get; set; }
}