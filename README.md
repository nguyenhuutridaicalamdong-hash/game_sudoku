# 🧩 Sudoku Sắc Màu

Game Sudoku trên điện thoại Android, viết bằng **Flutter**, có **đăng nhập**, **lưu điểm và bảng xếp hạng online** qua **Web API ASP.NET Core + SQL Server**, kèm **Góc giải trí** với 4 mini game xả stress.

> Đồ án môn **Lập trình thiết bị di động** – Lớp 23DTHC4

📱 **Tải APK:** [Releases – bản mới nhất](https://github.com/nguyenhuutridaicalamdong-hash/game_sudoku/releases/latest)

---

## 👥 Thành viên & phân công

| Thành viên | Vai trò | Công việc chính |
| :--- | :--- | :--- |
| **Nguyễn Hữu Trí** | Khởi tạo dự án & Gameplay | Tạo project Flutter, cấu trúc thư mục (models / providers / services / views), bàn cờ 9x9, bàn phím số, Ghi chú – Hoàn tác – Xóa – Gợi ý, màn hình Trang chủ / Chơi / Chiến thắng |
| **Hà Phương Bình** | Lưu trữ & Bảng xếp hạng | Lưu trữ dữ liệu người chơi và lịch sử ván, đồng bộ dữ liệu đám mây (bản đầu dùng Firebase Firestore), màn hình Bảng xếp hạng, Lịch sử, Hồ sơ |
| **Nguyễn Quốc Duy** | Backend, Cấp độ & Giao diện | Web API ASP.NET Core + SQL Server (JWT, điểm, lịch sử, xếp hạng), đăng ký / đăng nhập, 6 cấp độ + thuật toán sinh đề 1 lời giải, Việt hóa & giao diện mới, hiệu ứng, Góc giải trí, build APK & Dev Tunnel |

---

## ✨ Tính năng

### Sudoku
- **6 cấp độ** giống sudoku.com: Dễ · Trung bình · Khó · Chuyên gia · Bậc thầy · Cực khó (+ Thử thách ngày, cả server chung 1 đề)
- Đề sinh ngẫu nhiên, **luôn chỉ có đúng 1 lời giải** (kiểm tra bằng thuật toán quay lui + bitmask)
- Ghi chú, Hoàn tác, Xóa, Gợi ý (3 lần), tối đa 3 lỗi, đồng hồ, tạm dừng
- Số điền **đúng màu xanh**, **sai màu đỏ**; tô sáng hàng / cột / khối và các số giống nhau
- **Hiệu ứng** khi hoàn thành khối 3x3, hàng ngang, cột dọc (có **Combo**)
- Tự lưu ván đang chơi, nút **Chơi tiếp** nổi bật khi có ván dở

### Tài khoản & Online
- **Đăng ký / đăng nhập** (mật khẩu mã hóa BCrypt, token JWT)
- Điểm, EXP, cấp độ người chơi, chuỗi ngày chơi, thời gian tốt nhất từng cấp
- **Lịch sử ván chơi** và **Bảng xếp hạng** Tuần này / Tháng này / Mọi lúc
- Mất mạng vẫn chơi được, điểm **tự gửi lại** khi có kết nối
- Đổi địa chỉ máy chủ ngay trong app (máy ảo / cùng Wi-Fi / Dev Tunnel)

### 🎮 Góc giải trí
| Game | Mô tả |
| :--- | :--- |
| 🫧 Bóp bóng khí | Bóp tấm giấy bóng khí, có rung nhẹ – xả stress |
| 🃏 Lật thẻ trí nhớ | Tìm 8 cặp hình giống nhau, lưu kỷ lục ít lượt nhất |
| ⚡ Bấm số thần tốc | Bấm 1 → 25 nhanh nhất, sai bị cộng 1 giây |
| ❌ Cờ caro 3x3 | Đấu với máy, chế độ Dễ / Khó (Khó dùng minimax – máy không thua) |

---

## 🛠️ Công nghệ

| Phần | Công nghệ |
| :--- | :--- |
| App di động | Flutter (Dart 3), Provider, SharedPreferences, http, Google Fonts |
| Web API | ASP.NET Core 8 Web API, Entity Framework Core, JWT Bearer, BCrypt, Swagger |
| Cơ sở dữ liệu | Microsoft SQL Server |
| Chia sẻ máy chủ | Visual Studio Dev Tunnels |

---

## 🏗️ Kiến trúc

```
 ┌────────────────────┐   HTTP/JSON + JWT   ┌──────────────────────┐   EF Core   ┌──────────────┐
 │   App Flutter      │ ──────────────────▶ │  SudokuApi           │ ──────────▶ │  SQL Server  │
 │ (Provider, views)  │ ◀────────────────── │  (ASP.NET Core 8)    │ ◀────────── │ SudokuGameDb │
 └────────────────────┘                     └──────────────────────┘             └──────────────┘
   Sinh đề Sudoku ngay trên máy               Tính điểm, EXP, chuỗi ngày,
   Lưu cache + ván dở (SharedPreferences)     bảng xếp hạng, tự sao lưu DB mỗi ngày
```

### Cơ sở dữ liệu

**Users** — `Id`, `Username` (duy nhất), `PasswordHash`, `DisplayName`, `TotalExp`, `TotalScore`, `PuzzlesCompleted`, `GamesPlayed`, `ZeroMistakeGames`, `StreakDays`, `LastPlayedDate`, `CreatedAt`

**GameRecords** — `Id`, `UserId` (FK → Users), `Difficulty`, `TimeSeconds`, `Mistakes`, `HintsUsed`, `Score`, `ExpEarned`, `IsCompleted`, `PlayedAt`

Script SQL tham khảo: [`backend/Database/SudokuGameDb.sql`](backend/Database/SudokuGameDb.sql)

### Các API chính

| Method | URL | Mô tả |
|---|---|---|
| POST | `/api/auth/register` | Đăng ký |
| POST | `/api/auth/login` | Đăng nhập, trả về token |
| GET / PUT | `/api/auth/me` 🔒 | Xem / đổi thông tin của tôi |
| POST | `/api/games` 🔒 | Lưu kết quả 1 ván |
| GET | `/api/games/me` 🔒 | Lịch sử ván chơi |
| GET | `/api/leaderboard?period=week\|month\|all` 🔒 | Bảng xếp hạng |
| GET | `/api/health` | Kiểm tra máy chủ |

Chi tiết + cách tính điểm: [`backend/README.md`](backend/README.md)

---

## 🚀 Cách chạy

### 1. Web API (Visual Studio 2022, .NET 8)
1. Mở `backend/SudokuApi/SudokuApi.csproj`
2. Sửa `ConnectionStrings:DefaultConnection` trong `appsettings.json` cho đúng SQL Server trên máy
   (vd `Server=.;...`, `Server=.\SQLEXPRESS;...` hoặc `Server=(localdb)\MSSQLLocalDB;...`)
3. Chọn profile **`lan`** → bấm ▶. Lần đầu chạy API **tự tạo database** `SudokuGameDb`
4. Swagger: `http://localhost:5260/swagger`

### 2. App Flutter (Android Studio / VS Code)
```bash
flutter pub get
flutter run
```
- Máy ảo Android gọi API qua `http://10.0.2.2:5260/api` (mặc định)
- Điện thoại thật: bấm dòng **"Máy chủ: …"** ở màn hình đăng nhập để nhập địa chỉ khác

### 3. Build APK
```bash
flutter build apk --release --split-per-abi --dart-define=API_URL=https://<link-dev-tunnel>/api
```
File ra: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

> Nếu project nằm ở ổ D mà pub cache ở ổ C, đã có sẵn `kotlin.incremental=false` trong `android/gradle.properties` để tránh lỗi *"different roots"*.

---

## 📁 Cấu trúc thư mục

```
game_sudoku/
├── lib/                          # App Flutter
│   ├── main.dart                 # Khởi tạo Provider, theme, màn hình Đăng nhập / vào game
│   ├── constants/app_colors.dart # Bảng màu
│   ├── models/                   # Difficulty, SudokuCell, BoardState, UserStats, GameRecord
│   ├── providers/                # AuthProvider, GameProvider, UserProvider, RankingProvider
│   ├── services/                 # SudokuGenerator, ApiService, ApiConfig, StorageService, AudioService
│   ├── views/
│   │   ├── auth/                 # Đăng nhập / Đăng ký
│   │   ├── home/  play/  game/   # Trang chủ, Chọn cấp độ, Bàn cờ
│   │   ├── victory/ history/     # Chiến thắng, Lịch sử
│   │   ├── ranking/ profile/     # Bảng xếp hạng, Hồ sơ
│   │   └── minigames/            # Góc giải trí (4 mini game)
│   └── widgets/                  # Header, thanh điều hướng, nền động, hiệu ứng hoàn thành
├── backend/
│   ├── SudokuApi/                # Web API: Controllers, Models, Data, Dtos, Services
│   ├── Database/SudokuGameDb.sql # Script tạo bảng (tham khảo)
│   └── README.md                 # Hướng dẫn API
├── test/widget_test.dart         # Test sinh đề (1 lời giải) & tính điểm
└── android/ ios/ web/ ...        # Mã nền tảng của Flutter
```

---

## 🧪 Kiểm thử
```bash
flutter test
```
Kiểm tra mọi cấp độ đều sinh đề hợp lệ, **duy nhất 1 lời giải**, và công thức tính điểm khớp với API.
