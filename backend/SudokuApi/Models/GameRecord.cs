using System.ComponentModel.DataAnnotations;

namespace SudokuApi.Models;

/// <summary>Bảng GameRecords: mỗi ván chơi (thắng hoặc thua) của người chơi.</summary>
public class GameRecord
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User? User { get; set; }

    /// <summary>easy | medium | hard | expert | master | extreme | daily</summary>
    [Required, MaxLength(20)]
    public string Difficulty { get; set; } = "easy";

    public int TimeSeconds { get; set; }
    public int Mistakes { get; set; }
    public int HintsUsed { get; set; }
    public int Score { get; set; }
    public int ExpEarned { get; set; }
    public bool IsCompleted { get; set; }

    public DateTime PlayedAt { get; set; } = DateTime.UtcNow;
}
