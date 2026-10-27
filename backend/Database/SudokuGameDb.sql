-- Script tham khảo cấu trúc database (API sẽ tự tạo khi chạy lần đầu,
-- KHÔNG bắt buộc phải chạy file này).
CREATE DATABASE SudokuGameDb;
GO
USE SudokuGameDb;
GO

CREATE TABLE Users (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    Username         NVARCHAR(50)  NOT NULL UNIQUE,
    PasswordHash     NVARCHAR(200) NOT NULL,
    DisplayName      NVARCHAR(100) NOT NULL,
    TotalExp         INT NOT NULL DEFAULT 0,
    TotalScore       INT NOT NULL DEFAULT 0,
    PuzzlesCompleted INT NOT NULL DEFAULT 0,
    GamesPlayed      INT NOT NULL DEFAULT 0,
    ZeroMistakeGames INT NOT NULL DEFAULT 0,
    StreakDays       INT NOT NULL DEFAULT 0,
    LastPlayedDate   DATETIME2 NULL,
    CreatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE GameRecords (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    UserId      INT NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    Difficulty  NVARCHAR(20) NOT NULL,   -- easy|medium|hard|expert|master|extreme|daily
    TimeSeconds INT NOT NULL,
    Mistakes    INT NOT NULL,
    HintsUsed   INT NOT NULL,
    Score       INT NOT NULL,
    ExpEarned   INT NOT NULL,
    IsCompleted BIT NOT NULL,
    PlayedAt    DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX IX_GameRecords_UserId_PlayedAt ON GameRecords(UserId, PlayedAt);
CREATE INDEX IX_GameRecords_PlayedAt ON GameRecords(PlayedAt);
GO

-- Ví dụ truy vấn bảng xếp hạng tuần:
-- SELECT u.DisplayName, SUM(g.Score) AS Score
-- FROM GameRecords g JOIN Users u ON u.Id = g.UserId
-- WHERE g.PlayedAt >= DATEADD(day, -7, SYSUTCDATETIME())
-- GROUP BY u.DisplayName ORDER BY Score DESC;
