using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using SudokuApi.Data;
using SudokuApi.Services;

var builder = WebApplication.CreateBuilder(args);

// ===== Database: SQL Server =====
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// ===== JWT =====
builder.Services.AddScoped<TokenService>();
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)),
        };
    });
builder.Services.AddAuthorization();

builder.Services.AddControllers();
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

// ===== Swagger (có nút Authorize để test token) =====
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Sudoku API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Dán token (không cần chữ Bearer)",
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" },
            },
            Array.Empty<string>()
        },
    });
});

var app = builder.Build();

// Bắt mọi lỗi và trả về JSON { message } để app Flutter hiện đúng nội dung lỗi
app.Use(async (context, next) =>
{
    try
    {
        await next();
    }
    catch (UnauthorizedAccessException ex)
    {
        context.Response.StatusCode = 401;
        await context.Response.WriteAsJsonAsync(new { message = ex.Message });
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Lỗi khi xử lý {Path}", context.Request.Path);
        context.Response.StatusCode = 500;
        await context.Response.WriteAsJsonAsync(new { message = "Lỗi máy chủ: " + (ex.InnerException?.Message ?? ex.Message) });
    }
});

// Tự tạo database + bảng nếu chưa có (KHÔNG xóa dữ liệu cũ)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();

    // Tự sao lưu database mỗi ngày 1 file (.bak) vào thư mục Backup mặc định của SQL Server
    if (app.Configuration.GetValue("Backup:Enabled", true))
    {
        try
        {
            var dbName = db.Database.GetDbConnection().Database;
            var fileName = $"{dbName}_{DateTime.Now:yyyyMMdd}.bak";
            var sql = $"BACKUP DATABASE [{dbName}] TO DISK = N'{fileName}' WITH INIT";
            db.Database.ExecuteSqlRaw(sql);
            app.Logger.LogInformation("Đã sao lưu database ra file {File} (thư mục Backup của SQL Server)", fileName);
        }
        catch (Exception ex)
        {
            app.Logger.LogWarning("Không sao lưu được database: {Message}", ex.Message);
        }
    }
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapGet("/", () => Results.Redirect("/swagger"));
// App Flutter gọi để kiểm tra kết nối máy chủ
app.MapGet("/api/health", () => Results.Ok(new { status = "ok", time = DateTime.UtcNow }));

app.Run();
