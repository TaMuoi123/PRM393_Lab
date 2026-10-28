# BÁO CÁO BÀI TẬP LAB 10 - PRM393
## Authentication, Session Management & Notifications

---

### 1. Tổng quan & Mục tiêu đạt được (Overview & Learning Outcomes)
Dự án đã hoàn thành **100% tất cả 6 bài lab (5 bài thành phần độc lập + 1 bài tích hợp tổng thể Lab10_Full)** theo đúng yêu cầu đề bài trong tài liệu môn học **PRM393**:

- **Lab 10.1 - Mock Login (15%)**:
  - Giao diện đăng nhập hiện đại Material 3 với xác thực biểu mẫu (`Flutter Form`, `TextFormField`, Regex kiểm tra định dạng email và mật khẩu tối thiểu 6 ký tự).
  - Ẩn/hiện mật khẩu trực quan.
  - Mô phỏng độ trễ xác thực backend với `Future.delayed` và tạo JWT token giả lập.
  - Hiển thị thanh tiến trình tải (`CircularProgressIndicator`) và thông báo lỗi qua `SnackBar`.
  - Điều hướng sang màn hình Dashboard hiển thị thông tin phiên và nút đăng xuất.
  - Cung cấp các nút chip điền nhanh tài khoản mẫu phục vụ chấm bài.

- **Lab 10.2 - Real REST API Login (20%)**:
  - Tích hợp gọi REST API thực tế từ DummyJSON (`POST https://dummyjson.com/auth/login`).
  - Gửi payload JSON chuẩn xác và phân tích dữ liệu JSON phản hồi: ID, họ tên, email, giới tính, URL ảnh đại diện (`image`), JWT `accessToken` & `refreshToken`.
  - Xử lý các tình huống lỗi mạng (`SocketException`), lỗi xác thực HTTP 400 (`Invalid credentials`) thân thiện với người dùng.
  - Trang hồ sơ cá nhân hiển thị ảnh đại diện trực tuyến, thông tin tài khoản và chi tiết token bảo mật.

- **Lab 10.3 - Auto Login & Logout (25%)**:
  - Lưu trữ và duy trì phiên đăng nhập cục bộ với `shared_preferences`.
  - Xây dựng màn hình khởi động thông minh (`SplashScreen`): tự động kiểm tra token đã lưu trong bộ nhớ máy.
  - **Auto-Login**: Nếu token hợp lệ tồn tại, ứng dụng tự động chuyển thẳng vào `HomeScreen` mà không bắt người dùng nhập lại tài khoản khi mở lại ứng dụng.
  - Cơ chế **Logout**: Xóa hoàn toàn session trong `SharedPreferences`, hủy token và đưa người dùng về lại `LoginScreen` (`pushAndRemoveUntil`).

- **Lab 10.4 - Firebase Authentication (Google Sign-In) (20%)**:
  - Tích hợp bộ thư viện chính thức: `firebase_core`, `firebase_auth`, `google_sign_in`.
  - Cấu hình file `firebase_options.dart` chuẩn nền tảng Flutter đa nền tảng (Android, Web, iOS).
  - Triển khai luồng Google Sign-In: Đăng nhập Google, lấy OAuth credential (`accessToken`, `idToken`) và xác thực vào Firebase (`signInWithCredential`).
  - Hiển thị hồ sơ người dùng Google (Avatar, Tên, Email, Firebase UID).
  - Đăng xuất đồng thời khỏi cả Firebase Auth và Google Sign-In.
  - **Chế độ Demo Google Sign-In (Simulator Mode)**: Cho phép chấm bài mượt mà ngay trên các máy ảo/thiết bị chưa cài Google Play Services hoặc chưa cấu hình mã vân tay SHA-1.

- **Lab 10.5 - Local Notifications (MANDATORY - LO7) (10%)**:
  - Tích hợp thư viện `flutter_local_notifications`.
  - Xin quyền thông báo `POST_NOTIFICATIONS` runtime theo chuẩn Android 13+ (API 33+).
  - Cấu hình kênh thông báo `prm393_lab10_notifications` với độ ưu tiên cao (`Importance.max`, `Priority.high`).
  - Cung cấp các nút kích hoạt thông báo tức thì, thông báo đăng nhập thành công (`LO7`) và biểu mẫu gửi thông báo tùy chỉnh.
  - Danh sách nhật ký lịch sử kích hoạt thông báo trực tiếp trên màn hình.

- **Lab 10_Full - Dự án tích hợp hoàn chỉnh (10%)**:
  - Tích hợp toàn diện 5 mô-đun vào một ứng dụng hoàn thiện duy nhất:
    1. `SplashScreen` kiểm tra phiên lưu trữ và điều hướng tự động.
    2. Đăng nhập linh hoạt qua 3 phương thức: **DummyJSON REST API**, **Firebase Google Sign-In**, hoặc **Mock Login**.
    3. Duy trì phiên đăng nhập và tự động đăng nhập khi mở lại app qua `SharedPreferences`.
    4. **Bắt buộc LO7**: Tự động bắn thông báo Local Notification ngay khi người dùng đăng nhập thành công (`🎉 Login Successful! Welcome back, [Tên]!`).
    5. Trung tâm quản lý thông báo và kiểm tra kết nối ngay trên màn hình chính Dashboard.
    6. Luồng đăng xuất an toàn: xóa phiên, bắn thông báo đăng xuất và trở về màn hình đăng nhập.

---

### 2. Cấu trúc thư mục nộp bài (Project Structure)

```text
PRM393_Lab10/
├── LAB 10_Authentication, Session Management & Notifications.docx  # Đề bài gốc
├── README.md                                                       # Báo cáo tổng thể bài Lab 10
│
├── Lab10_1_MockLogin/               # Bài 10.1: Mock Login & Form Validation
│   ├── lib/
│   ├── test/
│   ├── README.md
│   └── pubspec.yaml
│
├── Lab10_2_RealApiLogin/            # Bài 10.2: DummyJSON REST API Login
│   ├── lib/
│   ├── test/
│   ├── README.md
│   └── pubspec.yaml
│
├── Lab10_3_AutoLogin_Logout/        # Bài 10.3: Auto-login & SharedPreferences Session
│   ├── lib/
│   ├── test/
│   ├── README.md
│   └── pubspec.yaml
│
├── Lab10_4_FirebaseGoogleSignIn/    # Bài 10.4: Firebase & Google Sign-In
│   ├── lib/
│   ├── test/
│   ├── README.md
│   └── pubspec.yaml
│
├── Lab10_5_Notification/            # Bài 10.5: Local Notifications (LO7)
│   ├── lib/
│   ├── test/
│   ├── README.md
│   └── pubspec.yaml
│
├── Lab10_Full/                      # Bài tích hợp toàn diện Full Features
│   ├── lib/
│   ├── test/
│   ├── README.md
│   └── pubspec.yaml
│
├── Lab10_1_MockLogin.zip            # File nén nộp bài độc lập 1
├── Lab10_2_RealApiLogin.zip         # File nén nộp bài độc lập 2
├── Lab10_3_AutoLogin_Logout.zip     # File nén nộp bài độc lập 3
├── Lab10_4_FirebaseGoogleSignIn.zip # File nén nộp bài độc lập 4
├── Lab10_5_Notification.zip         # File nén nộp bài độc lập 5
└── Lab10_Full.zip                   # File nén nộp bài tích hợp hoàn chỉnh
```

---

### 3. Bảng tài khoản kiểm thử (Test Accounts Summary)

| Dự án | Phương thức | Tài khoản / Email | Mật khẩu | Ghi chú |
| :--- | :--- | :--- | :--- | :--- |
| **Lab 10.1** | Mock Login | `muoitthe182380@fpt.edu.vn` | `password123` | Tài khoản sinh viên Tạ Mười (HE182380) |
| **Lab 10.1** | Mock Login | `admin@fpt.edu.vn` | `Admin@123` | Tài khoản quản trị viên |
| **Lab 10.2** | DummyJSON API | `emilys` | `emilyspass` | Tài khoản Emily Johnson (ID: 1) |
| **Lab 10.2** | DummyJSON API | `michaelw` | `michaelwpass` | Tài khoản Michael Williams (ID: 2) |
| **Lab 10.3** | SharedPreferences | `emilys` / `offline` | `emilyspass` / `password123` | Tự động ghi nhớ phiên sau khi đăng nhập |
| **Lab 10.4** | Google Sign-In | Nút Sign in with Google | Tài khoản Google của bạn | Yêu cầu Google Play Services |
| **Lab 10.4** | Google Demo | Nút Demo Google Sign-In | Không cần | Chạy ngay trên mọi máy ảo không cần SHA-1 |
| **Lab 10.5** | Local Notifications | Không cần | Không cần | Bấm nút Demo để bắn thông báo ngay lập tức |
| **Lab10_Full**| Đầy đủ các phương thức | Hỗ trợ cả 3 hình thức trên | Như trên | Tự động bắn thông báo khi đăng nhập thành công |

---

### 4. Hướng dẫn chạy và kiểm thử từng dự án (How to Run)

Mỗi dự án thành phần đều hoạt động độc lập (`runnable Flutter project`):

```bash
# 1. Chạy Lab 10.1 (Mock Login)
cd Lab10_1_MockLogin
flutter pub get
flutter run

# 2. Chạy Lab 10.2 (Real API Login)
cd ../Lab10_2_RealApiLogin
flutter pub get
flutter run

# 3. Chạy Lab 10.3 (Auto Login & Logout)
cd ../Lab10_3_AutoLogin_Logout
flutter pub get
flutter run

# 4. Chạy Lab 10.4 (Firebase Google Sign-In)
cd ../Lab10_4_FirebaseGoogleSignIn
flutter pub get
flutter run

# 5. Chạy Lab 10.5 (Local Notifications)
cd ../Lab10_5_Notification
flutter pub get
flutter run

# 6. Chạy Lab10_Full (Dự án tích hợp đầy đủ)
cd ../Lab10_Full
flutter pub get
flutter run
```

Để chạy bộ kiểm thử tự động (Unit & Widget Test):
```bash
flutter test
```
Tất cả các dự án đều đạt kết quả kiểm thử **100% Passed** và **0 cảnh báo linter** (`flutter analyze`).
