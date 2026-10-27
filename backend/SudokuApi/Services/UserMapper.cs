using Microsoft.EntityFrameworkCore;
using SudokuApi.Data;
using SudokuApi.Dtos;
using SudokuApi.Models;

namespace SudokuApi.Services;

public static class UserMapper
{
    /// <summary>Chuyển User sang UserDto, kèm thời gian tốt nhất của từng độ khó.</summary>
    public static async Task<UserDto> ToDtoAsync(AppDbContext db, User user)
    {
        var bestTimes = await db.GameRecords
            .Where(g => g.UserId == user.Id && g.IsCompleted)
            .GroupBy(g => g.Difficulty)
            .Select(g => new { Difficulty = g.Key, Best = g.Min(x => x.TimeSeconds) })
            .ToDictionaryAsync(x => x.Difficulty, x => x.Best);

        // Nếu hôm qua và hôm nay đều không chơi thì chuỗi ngày đã bị đứt
        var streak = user.StreakDays;
        if (user.LastPlayedDate == null || user.LastPlayedDate.Value.Date < ScoreCalculator.TodayVn().AddDays(-1))
        {
            streak = 0;
        }

        return new UserDto(
            user.Id,
            user.Username,
            user.DisplayName,
            user.TotalExp,
            user.TotalScore,
            user.PuzzlesCompleted,
            user.GamesPlayed,
            user.ZeroMistakeGames,
            streak,
            bestTimes,
            user.CreatedAt);
    }

    public static GameRecordDto ToDto(GameRecord g) => new(
        g.Id, g.Difficulty, g.TimeSeconds, g.Mistakes, g.HintsUsed,
        g.Score, g.ExpEarned, g.IsCompleted,
        // SQL Server không lưu "Kind" → đánh dấu lại là UTC để app đổi đúng giờ VN
        DateTime.SpecifyKind(g.PlayedAt, DateTimeKind.Utc));
}
