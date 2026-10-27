using System.ComponentModel.DataAnnotations;

namespace SudokuApi.Models;

/// <summary>Bảng Users: tài khoản người chơi + thống kê tổng hợp.</summary>
public class User
{
    public int Id { get; set; }

    [Required, MaxLength(50)]
    public string Username { get; set; } = string.Empty;

    [Required, MaxLength(200)]
    public string PasswordHash { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    public string DisplayName { get; set; } = string.Empty;

    public int TotalExp { get; set; }
    public int TotalScore { get; set; }
    public int PuzzlesCompleted { get; set; }
    public int GamesPlayed { get; set; }
    public int ZeroMistakeGames { get; set; }
    public int StreakDays { get; set; }

    /// <summary>Ngày chơi gần nhất (giờ Việt Nam), dùng để tính chuỗi ngày.</summary>
    public DateTime? LastPlayedDate { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public List<GameRecord> GameRecords { get; set; } = new();
}
