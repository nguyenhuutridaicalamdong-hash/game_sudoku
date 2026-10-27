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
public class AuthController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly TokenService _tokenService;

    public AuthController(AppDbContext db, TokenService tokenService)
    {
        _db = db;
        _tokenService = tokenService;
    }

    // POST api/auth/register
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterRequest req)
    {
        var username = req.Username.Trim().ToLower();

        if (await _db.Users.AnyAsync(u => u.Username == username))
        {
            return BadRequest(new { message = "Tên đăng nhập đã tồn tại" });
        }

        var user = new User
        {
            Username = username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            DisplayName = req.DisplayName.Trim(),
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        var token = _tokenService.CreateToken(user);
        return Ok(new AuthResponse(token, await UserMapper.ToDtoAsync(_db, user)));
    }

    // POST api/auth/login
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginRequest req)
    {
        var username = req.Username.Trim().ToLower();
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Username == username);

        if (user == null || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
        {
            return Unauthorized(new { message = "Sai tên đăng nhập hoặc mật khẩu" });
        }

        var token = _tokenService.CreateToken(user);
        return Ok(new AuthResponse(token, await UserMapper.ToDtoAsync(_db, user)));
    }

    // GET api/auth/me  (cần token)
    [Authorize]
    [HttpGet("me")]
    public async Task<ActionResult<UserDto>> Me()
    {
        var userId = User.GetUserId();
        var user = await _db.Users.FindAsync(userId);
        if (user == null) return Unauthorized();
        return Ok(await UserMapper.ToDtoAsync(_db, user));
    }

    // PUT api/auth/me  (đổi tên hiển thị)
    [Authorize]
    [HttpPut("me")]
    public async Task<ActionResult<UserDto>> UpdateProfile(UpdateProfileRequest req)
    {
        var userId = User.GetUserId();
        var user = await _db.Users.FindAsync(userId);
        if (user == null) return Unauthorized();

        user.DisplayName = req.DisplayName.Trim();
        await _db.SaveChangesAsync();
        return Ok(await UserMapper.ToDtoAsync(_db, user));
    }
}
