using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SudokuApi.Data;
using SudokuApi.Dtos;
using SudokuApi.Services;

namespace SudokuApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LeaderboardController : ControllerBase
{
    private readonly AppDbContext _db;

    public LeaderboardController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// GET api/leaderboard?period=week|month|all&difficulty=hard&top=20
    /// Xếp hạng theo tổng điểm các ván trong khoảng thời gian.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<LeaderboardEntryDto>>> Get(
        [FromQuery] string period = "week",
        [FromQuery] string? difficulty = null,
        [FromQuery] int top = 20)
    {
        top = Math.Clamp(top, 1, 100);
        var currentUserId = User.GetUserId();

        var query = _db.GameRecords.AsNoTracking().AsQueryable();

        if (period == "week")
        {
            var since = DateTime.UtcNow.AddDays(-7);
            query = query.Where(g => g.PlayedAt >= since);
        }
        else if (period == "month")
        {
            var since = DateTime.UtcNow.AddDays(-30);
            query = query.Where(g => g.PlayedAt >= since);
        }

        if (!string.IsNullOrWhiteSpace(difficulty))
        {
            var d = difficulty.Trim().ToLower();
            query = query.Where(g => g.Difficulty == d);
        }

        // Lấy dữ liệu gọn rồi gom nhóm trong bộ nhớ (dễ hiểu, tránh lỗi dịch câu SQL)
        var rows = await query
            .Select(g => new { g.UserId, g.Score, g.IsCompleted })
            .ToListAsync();

        var grouped = rows
            .GroupBy(g => g.UserId)
            .Select(g => new
            {
                UserId = g.Key,
                Score = g.Sum(x => x.Score),
                GamesWon = g.Count(x => x.IsCompleted),
            })
            .OrderByDescending(x => x.Score)
            .ThenByDescending(x => x.GamesWon)
            .ToList();

        var userIds = grouped.Select(x => x.UserId).ToList();
        var users = await _db.Users.AsNoTracking()
            .Where(u => userIds.Contains(u.Id))
            .ToDictionaryAsync(u => u.Id);

        var result = new List<LeaderboardEntryDto>();
        for (int i = 0; i < grouped.Count; i++)
        {
            var row = grouped[i];
            var isMe = row.UserId == currentUserId;
            // Lấy top N, nhưng luôn kèm theo dòng của chính mình
            if (i >= top && !isMe) continue;
            if (!users.TryGetValue(row.UserId, out var u)) continue;
            result.Add(new LeaderboardEntryDto(i + 1, u.Id, u.DisplayName, row.Score, row.GamesWon, u.StreakDays, isMe));
        }

        return Ok(result);
    }
}
