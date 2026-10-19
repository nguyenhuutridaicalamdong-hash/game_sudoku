# 🧩 Sudoku Mindful Logic (Flutter Mobile Game)

Dự án game Sudoku Mobile phát triển bằng **Flutter & Dart**, giữ nguyên 100% phong cách thiết kế giao diện Google Stitch (Mindful Pastel & 3D Tactile UI), được cấu trúc tối ưu cho **Đồ án môn Lập trình thiết bị di động (Nhóm 4 sinh viên)**.

---

## 🚀 Hướng dẫn mở và chạy trên VS Code

### 1. Mở dự án trong VS Code
1. Mở **VS Code**.
2. Chọn menu **File** -> **Open Folder...** (hoặc `Ctrl + K, Ctrl + O`).
3. Chọn thư mục: `D:\sudoku_flutter`.
4. Nếu chưa cài Flutter Extension trên VS Code, hãy vào tab **Extensions** (`Ctrl + Shift + X`) và cài đặt:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

### 2. Chạy ứng dụng (Run / Debug)
- **Cách 1 (Nhanh nhất)**: Nhấn phím `F5` trên bàn phím. VS Code sẽ tự động chạy cấu hình trong `.vscode/launch.json`.
- **Cách 2 (Qua Terminal)**:
  - Mở Terminal trong VS Code (`Ctrl + ~`).
  - Chọn thiết bị muốn chạy:
    ```bash
    # Chạy trên điện thoại Android thật hoặc máy ảo Android
    flutter run

    # Chạy test nhanh trên Chrome
    flutter run -d chrome

    # Chạy trực tiếp trên máy tính Windows
    flutter run -d windows
    ```

---

## 📱 Cấu trúc thư mục mã nguồn (`lib/`)

```
lib/
├── main.dart                 # Khởi chạy MultiProvider, Theme GoogleFonts & MaterialApp
├── constants/
│   └── app_colors.dart       # Toàn bộ mã màu chuẩn Stitch (#FAF8FF, #4145DA, #FEA619, #6FFBBE...)
├── models/
│   ├── difficulty.dart       # Enum Easy, Medium, Hard, Expert, Daily kèm màu sắc & icon
│   ├── sudoku_cell.dart      # Dữ liệu ô cờ (row, col, value, solution, isGiven, notes...)
│   ├── board_state.dart      # Trạng thái ván cờ, undo history stack
│   ├── user_stats.dart       # Thông tin người chơi (Tên, level, EXP, streak, settings)
│   └── game_record.dart      # Lịch sử từng ván đấu (Thời gian, độ khó, điểm số, ngày giờ)
├── services/
│   ├── sudoku_generator.dart # Thuật toán Backtracking sinh đề ngẫu nhiên & giải Sudoku
│   ├── storage_service.dart  # Lưu trữ offline SharedPreferences (Tự động lưu ván dở & kỷ lục)
│   └── audio_service.dart    # Hiệu ứng âm thanh click & rung phản hồi xúc giác (Haptic)
├── providers/
│   ├── game_provider.dart    # Quản lý toàn bộ vòng đời game, timer, undo, hint, win/loss
│   ├── user_provider.dart    # Quản lý điểm số, EXP, cấp độ, lưu lịch sử ván đấu
│   └── ranking_provider.dart # Quản lý bảng xếp hạng Master League
├── widgets/
│   ├── tactile_button.dart   # Nút bấm 3D nổi khối đổ bóng theo phong cách Stitch
│   ├── custom_header.dart    # Thanh Header trên cùng (Logo, Sound toggle, Profile)
│   └── bottom_nav_bar.dart   # Thanh điều hướng đáy nổi 4 tab bo tròn
└── views/
    ├── main_navigation.dart  # Scaffold chính điều phối tab và màn hình cờ/chiến thắng
    ├── home/home_view.dart   # Màn hình Trang chủ (Streak, 3D tiles, Play button, Daily, Continue)
    ├── play/play_view.dart   # Màn hình Chọn cấp độ cờ (Easy, Medium, Hard, Expert)
    ├── game/game_board_view.dart # Bàn cờ 9x9 (Numpad 1-9, Notes, Undo, Erase, Hint, Pause)
    ├── victory/victory_view.dart # Màn hình Chiến thắng (Pháo hoa Confetti Canvas, cúp vàng 3D)
    ├── ranking/ranking_view.dart # Bảng xếp hạng Master League (This Week, All Time, Friends)
    ├── profile/profile_view.dart # Hồ sơ cá nhân & cài đặt âm thanh, rung, highlight
    └── history/history_view.dart # Lịch sử các ván cờ đã chơi (Chi tiết ngày, độ khó, điểm, thời gian)
```

---

## 👥 Phân chia công việc cho Nhóm 4 Sinh viên

| Thành viên | Nhiệm vụ chính | Các file phụ trách |
| :--- | :--- | :--- |
| **Thành viên 1** | **Gameplay Engine & Thuật toán** | `lib/services/sudoku_generator.dart`, `lib/views/game/game_board_view.dart`, `lib/providers/game_provider.dart` |
| **Thành viên 2** | **UI/UX & Hoạt ảnh ăn mừng** | `lib/views/home/home_view.dart`, `lib/views/play/play_view.dart`, `lib/views/victory/victory_view.dart` |
| **Thành viên 3** | **Lịch sử ván cờ & Hệ thống Điểm/EXP** | `lib/views/history/history_view.dart`, `lib/models/game_record.dart`, `lib/services/storage_service.dart`, `lib/providers/user_provider.dart` |
| **Thành viên 4** | **Bảng xếp hạng, Tài khoản & Build Android APK** | `lib/views/ranking/ranking_view.dart`, `lib/views/profile/profile_view.dart`, cấu hình Android Manifest & xuất APK |
