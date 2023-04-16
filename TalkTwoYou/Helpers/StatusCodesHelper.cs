using Microsoft.AspNetCore.Mvc;

namespace TalkTwoYou.Helpers;

public class StatusCodesHelper
{
    public static int? GetStatusCode(IActionResult result)
    {
        return result switch
        {
            ObjectResult objectResult => objectResult.StatusCode,
            StatusCodeResult statusCodeResult => statusCodeResult.StatusCode,
            ContentResult contentResult => contentResult.StatusCode,
            _ => throw new Exception("not found")
        };
    }
}