# SudokuApi – Web API ASP.NET Core + SQL Server

API lưu **tài khoản người chơi, điểm, lịch sử ván chơi và bảng xếp hạng** cho app Flutter.

## Chạy API
1. Mở `backend/SudokuApi/SudokuApi.csproj` bằng **Visual Studio 2022** (cần .NET 8 SDK trở lên).
2. Sửa chuỗi kết nối trong `appsettings.json` cho đúng SQL Server trên máy:
   - SQL Server bản thường: `Server=.;...` (mặc định)
   - SQL Express: `Server=.\\SQLEXPRESS;...`
   - LocalDB: `Server=(localdb)\\MSSQLLocalDB;...`
3. Chọn profile **http** → bấm ▶. Trình duyệt mở Swagger tại `http://localhost:5260/swagger`.
4. Lần chạy đầu API **tự tạo database `SudokuGameDb`** và 2 bảng `Users`, `GameRecords`
   (không cần Add-Migration). File `Database/SudokuGameDb.sql` chỉ để tham khảo/báo cáo.

> App Flutter trên máy ảo gọi `http://10.0.2.2:5260/api` (xem `lib/services/api_config.dart`).
> Phải để API chạy thì app mới đăng nhập được.

## Các API
| Method | URL | Mô tả |
|---|---|---|
| POST | `/api/auth/register` | Đăng ký `{username, password, displayName}` → `{token, user}` |
| POST | `/api/auth/login` | Đăng nhập `{username, password}` → `{token, user}` |
| GET | `/api/auth/me` 🔒 | Thông tin + điểm của tôi |
| PUT | `/api/auth/me` 🔒 | Đổi tên hiển thị |
| POST | `/api/games` 🔒 | Lưu kết quả 1 ván `{difficulty, timeSeconds, mistakes, hintsUsed, isCompleted}` |
| GET | `/api/games/me` 🔒 | Lịch sử ván chơi của tôi |
| GET | `/api/leaderboard?period=week\|month\|all` 🔒 | Bảng xếp hạng theo tổng điểm |

🔒 = cần header `Authorization: Bearer <token>` (trong Swagger bấm **Authorize** rồi dán token).

## Cách tính điểm (giống `lib/models/difficulty.dart`)
`điểm = điểm gốc + thưởng thời gian − 80 × lỗi − 50 × gợi ý` (tối thiểu 100, thua = 0)

| Cấp | Ô gợi ý | Điểm gốc | Thời gian chuẩn |
|---|---|---|---|
| Dễ | 38–40 | 400 | 5 phút |
| Trung bình | 32–34 | 650 | 8 phút |
| Khó | 28–30 | 900 | 12 phút |
| Chuyên gia | 26–27 | 1200 | 15 phút |
| Bậc thầy | 24–25 | 1500 | 20 phút |
| Cực khó | 22–23 | 1800 | 25 phút |

Thưởng thời gian = số giây giải nhanh hơn thời gian chuẩn. EXP: thắng 100 (không lỗi 150), thua 20.
