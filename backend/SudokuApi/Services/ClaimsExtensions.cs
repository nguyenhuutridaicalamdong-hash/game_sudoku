using System.Security.Claims;

namespace SudokuApi.Services;

public static class ClaimsExtensions
{
    /// <summary>
    /// Lấy Id người chơi từ token. Thử nhiều tên claim vì .NET có thể đổi tên claim
    /// khi đọc token (nameidentifier / nameid / sub).
    /// </summary>
    public static int GetUserId(this ClaimsPrincipal user)
    {
        var value = user.FindFirst("uid")?.Value
                    ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                    ?? user.FindFirst("nameid")?.Value
                    ?? user.FindFirst("sub")?.Value;

        if (int.TryParse(value, out var id)) return id;
        throw new UnauthorizedAccessException("Token không hợp lệ, vui lòng đăng nhập lại");
    }
}
