using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SudokuApi.Data;
using SudokuApi.Dtos;
using SudokuApi.Models;
using SudokuApi.Services;

namespace SudokuApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GamesController : ControllerBase
{
    private readonly AppDbContext _db;

    public GamesController(AppDbContext db)
    {
        _db = db;
    }

    private int CurrentUserId => User.GetUserId();

    // POST api/games  → lưu kết quả 1 ván, cập nhật điểm/EXP/chuỗi ngày
    [HttpPost]
    public async Task<ActionResult<SubmitGameResponse>> Submit(SubmitGameRequest req)
    {
        var difficulty = req.Difficulty.Trim().ToLower();
        if (!ScoreCalculator.IsValid(difficulty))
        {
            return BadRequest(new { message = "Độ khó không hợp lệ" });
        }

        var user = await _db.Users.FindAsync(CurrentUserId);
        if (user == null) return Unauthorized();

        // Kiểm tra kỷ lục cũ trước khi lưu ván mới
        int? prevBest = await _db.GameRecords
            .Where(g => g.UserId == user.Id && g.IsCompleted && g.Difficulty == difficulty)
            .Select(g => (int?)g.TimeSeconds)
            .MinAsync();
        var isNewBest = req.IsCompleted && (prevBest == null || req.TimeSeconds < prevBest);

        var score = ScoreCalculator.ComputeScore(difficulty, req.TimeSeconds, req.Mistakes, req.HintsUsed, req.IsCompleted);
        var exp = ScoreCalculator.ComputeExp(req.Mistakes, req.IsCompleted);

        var record = new GameRecord
        {
            UserId = user.Id,
            Difficulty = difficulty,
            TimeSeconds = req.TimeSeconds,
            Mistakes = req.Mistakes,
            HintsUsed = req.HintsUsed,
            Score = score,
            ExpEarned = exp,
            IsCompleted = req.IsCompleted,
            PlayedAt = DateTime.UtcNow,
        };
        _db.GameRecords.Add(record);

        // Cập nhật thống kê người chơi
        user.GamesPlayed += 1;
        user.TotalExp += exp;
        user.TotalScore += score;
        if (req.IsCompleted)
        {
            user.PuzzlesCompleted += 1;
            if (req.Mistakes == 0) user.ZeroMistakeGames += 1;
        }

        // Chuỗi ngày chơi liên tiếp
        var today = ScoreCalculator.TodayVn();
        if (user.LastPlayedDate == null || user.LastPlayedDate.Value.Date < today.AddDays(-1))
        {
            user.StreakDays = 1;
        }
        else if (user.LastPlayedDate.Value.Date == today.AddDays(-1))
        {
            user.StreakDays += 1;
        }
        user.LastPlayedDate = today;

        await _db.SaveChangesAsync();

        return Ok(new SubmitGameResponse(
            UserMapper.ToDto(record),
            await UserMapper.ToDtoAsync(_db, user),
            isNewBest));
    }

    // GET api/games/me?take=50  → lịch sử ván chơi của tôi
    [HttpGet("me")]
    public async Task<ActionResult<List<GameRecordDto>>> MyGames([FromQuery] int take = 50)
    {
        take = Math.Clamp(take, 1, 200);
        var userId = CurrentUserId;
        var records = await _db.GameRecords
            .Where(g => g.UserId == userId)
            .OrderByDescending(g => g.PlayedAt)
            .Take(take)
            .ToListAsync();

        return Ok(records.Select(UserMapper.ToDto).ToList());
    }
}
