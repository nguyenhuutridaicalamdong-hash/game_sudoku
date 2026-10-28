using System.ComponentModel.DataAnnotations;

namespace SudokuApi.Dtos;

// ===== Auth =====
public class RegisterRequest
{
    [Required, MinLength(3), MaxLength(50)]
    [RegularExpression("^[a-zA-Z0-9_.]+$", ErrorMessage = "Tên đăng nhập chỉ gồm chữ không dấu, số, dấu _ hoặc .")]
    public string Username { get; set; } = string.Empty;

    [Required, MinLength(6), MaxLength(100)]
    public string Password { get; set; } = string.Empty;

    [Required, MinLength(1), MaxLength(100)]
    public string DisplayName { get; set; } = string.Empty;
}

public class LoginRequest
{
    [Required]
    public string Username { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;
}

public record AuthResponse(string Token, UserDto User);

// ===== User =====
public record UserDto(
    int Id,
    string Username,
    string DisplayName,
    int TotalExp,
    int TotalScore,
    int PuzzlesCompleted,
    int GamesPlayed,
    int ZeroMistakeGames,
    int StreakDays,
    Dictionary<string, int> BestTimes,
    DateTime CreatedAt);

public class UpdateProfileRequest
{
    [Required, MinLength(1), MaxLength(100)]
    public string DisplayName { get; set; } = string.Empty;
}

// ===== Games =====
public class SubmitGameRequest
{
    [Required]
    public string Difficulty { get; set; } = "easy";

    [Range(0, 86400)]
    public int TimeSeconds { get; set; }

    [Range(0, 100)]
    public int Mistakes { get; set; }

    [Range(0, 100)]
    public int HintsUsed { get; set; }

    public bool IsCompleted { get; set; }
}

public record GameRecordDto(
    int Id,
    string Difficulty,
    int TimeSeconds,
    int Mistakes,
    int HintsUsed,
    int Score,
    int ExpEarned,
    bool IsCompleted,
    DateTime PlayedAt);

public record SubmitGameResponse(GameRecordDto Record, UserDto User, bool IsNewBestTime);

// ===== Leaderboard =====
public record LeaderboardEntryDto(
    int Rank,
    int UserId,
    string DisplayName,
    int Score,
    int GamesWon,
    int StreakDays,
    bool IsCurrentUser,
    int TotalTimeSeconds,                 // tổng thời gian các ván đã giải trong kỳ
    Dictionary<string, int> Solved,       // số ván đã giải theo cấp độ, vd { "easy": 3, "hard": 1 }
    Dictionary<string, int> BestTimes);   // thời gian tốt nhất (giây) theo cấp độ
