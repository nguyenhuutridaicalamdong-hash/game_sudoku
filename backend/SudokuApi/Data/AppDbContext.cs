using Microsoft.EntityFrameworkCore;
using SudokuApi.Models;

namespace SudokuApi.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<GameRecord> GameRecords => Set<GameRecord>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Username)
            .IsUnique();

        modelBuilder.Entity<GameRecord>()
            .HasOne(g => g.User)
            .WithMany(u => u.GameRecords)
            .HasForeignKey(g => g.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<GameRecord>()
            .HasIndex(g => new { g.UserId, g.PlayedAt });

        modelBuilder.Entity<GameRecord>()
            .HasIndex(g => g.PlayedAt);
    }
}
