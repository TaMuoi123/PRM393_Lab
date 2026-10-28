# Weather Companion App - Lab 8B (PRM393)
> **Practical REST API Integration: Turning API Data into Useful Apps**

Ứng dụng Flutter thông minh tiêu thụ REST API thời tiết theo thời gian thực (Open-Meteo) và chuyển đổi dữ liệu thành các khuyến nghị thiết thực hàng ngày cho người dùng:
- **Tư vấn mang dù / áo mưa** (dựa trên xác suất mưa và lượng mưa thực tế).
- **Lập kế hoạch thể thao ngoài trời** (đánh giá nhiệt độ, gió, dông bão).
- **Gợi ý trang phục phù hợp** (dựa vào cảm nhận nhiệt thực tế).
- **Dự báo chi tiết 24 giờ tới và 7 ngày tới**.
- **Tìm kiếm thành phố toàn cầu** qua REST Geocoding API.

---

## Cấu trúc thư mục dự án
```
lib/
├── main.dart                          # Khởi tạo App & Theme
├── models/
│   ├── location_model.dart            # Model địa điểm & Geocoding
│   ├── weather_model.dart             # Model thời tiết đầy đủ
│   └── weather_recommendation.dart    # Logic tính toán tư vấn tiện ích
├── services/
│   └── weather_service.dart           # Tầng Service gọi REST API với http
├── widgets/
│   ├── weather_header.dart            # Header hiển thị thời tiết hiện tại
│   ├── recommendation_cards.dart      # Các thẻ tư vấn (Dù, Hoạt động, Trang phục)
│   ├── hourly_forecast_view.dart      # Dự báo 24 giờ tới
│   ├── daily_forecast_view.dart       # Dự báo 7 ngày tới
│   ├── weather_details_grid.dart      # 4 chỉ số khí tượng chi tiết
│   ├── city_search_sheet.dart         # Hộp thoại tìm kiếm thành phố
│   └── error_view.dart                # Giao diện thông báo lỗi & nút Thử lại
└── screens/
    ├── home_screen.dart               # Màn hình chính (FutureBuilder + States)
    └── detail_screen.dart             # Màn hình bảng thông số chi tiết
```

---

## Hướng dẫn chạy ứng dụng
1. Cài đặt các gói phụ thuộc:
   ```bash
   flutter pub get
   ```
2. Chạy kiểm thử tự động:
   ```bash
   flutter test
   flutter analyze
   ```
3. Chạy ứng dụng trên Web hoặc Windows:
   ```bash
   flutter run -d chrome
   # hoặc
   flutter run -d windows
   ```
---
Xem chi tiết đầy đủ trong file: [LAB_8B_REPORT.md](LAB_8B_REPORT.md)
