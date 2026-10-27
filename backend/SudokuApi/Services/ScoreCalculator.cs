namespace SudokuApi.Services;

/// <summary>
/// Cách tính điểm/EXP. PHẢI GIỐNG với lib/models/difficulty.dart bên Flutter
/// (Difficulty.computeScore / computeExp).
/// </summary>
public static class ScoreCalculator
{
    public static readonly string[] ValidDifficulties =
        { "easy", "medium", "hard", "expert", "master", "extreme", "daily" };

    public static bool IsValid(string difficulty) => ValidDifficulties.Contains(difficulty);

    public static int BaseScore(string difficulty) => difficulty switch
    {
        "easy" => 400,
        "medium" => 650,
        "hard" => 900,
        "expert" => 1200,
        "master" => 1500,
        "extreme" => 1800,
        "daily" => 800,
        _ => 400,
    };

    /// <summary>Thời gian chuẩn (giây). Giải nhanh hơn mốc này thì được cộng điểm thưởng.</summary>
    public static int ParTimeSeconds(string difficulty) => difficulty switch
    {
        "easy" => 300,
        "medium" => 480,
        "hard" => 720,
        "expert" => 900,
        "master" => 1200,
        "extreme" => 1500,
        "daily" => 600,
        _ => 600,
    };

    public static int ComputeScore(string difficulty, int timeSeconds, int mistakes, int hintsUsed, bool isCompleted)
    {
        if (!isCompleted) return 0;
        var par = ParTimeSeconds(difficulty);
        var timeBonus = Math.Clamp(par - timeSeconds, 0, par);
        var score = BaseScore(difficulty) + timeBonus - mistakes * 80 - hintsUsed * 50;
        return Math.Clamp(score, 100, 5000);
    }

    public static int ComputeExp(int mistakes, bool isCompleted)
    {
        if (!isCompleted) return 20;
        return mistakes == 0 ? 150 : 100;
    }

    /// <summary>Ngày hiện tại theo giờ Việt Nam (UTC+7).</summary>
    public static DateTime TodayVn() => DateTime.UtcNow.AddHours(7).Date;
}
