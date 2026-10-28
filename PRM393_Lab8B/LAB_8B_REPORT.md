# BÁO CÁO THỰC HÀNH LAB 8B: PRACTICAL REST API INTEGRATION
## Turning API Data into Useful Apps (PRM393)

---

### 1. Thông Tin Chung
* **Môn học:** PRM393 - Lập trình Di động (Mobile Programming)
* **Bài Lab:** Lab 8B - Practical REST API Integration: Turning API Data into Useful Apps
* **Kịch bản lựa chọn (Scenario):** **Scenario A - Weather Companion App (Trợ lý Thời tiết & Hoạt động Hàng ngày)**
* **Công nghệ sử dụng:** Flutter SDK 3.47.2, Dart 3.13.2, Thư viện `http`, `intl`
* **REST API thực tế:** [Open-Meteo Weather & Geocoding REST API](https://open-meteo.com) (API chuẩn quốc tế, dữ liệu khí tượng thời gian thực, không yêu cầu API key)

---

### 2. Mục Tiêu & Vấn Đề Ứng Dụng Giải Quyết (Purpose-Driven UX)
Khác với ứng dụng thời tiết chỉ hiển thị một danh sách số liệu khô khan, **Weather Companion App** chuyển hóa dữ liệu khí tượng thời gian thực từ REST API thành các quyết định và khuyến nghị hữu ích cho người dùng:
1. **"Hôm nay có cần mang dù hoặc áo mưa không?" (Umbrella Advisor):**
   * Tự động phân tích lượng mưa hiện tại (`precipitation`), mã thời tiết (`weather_code`) và xác suất mưa (`precipitation_probability`) trong 12 giờ tới.
   * Đưa ra khuyến cáo trực quan: *Cần mang dù* kèm cảnh báo tỉ lệ mưa, hoặc *Không cần mang dù* khi trời tạnh ráo.
2. **"Thời tiết hôm nay có thích hợp cho hoạt động ngoài trời không?" (Outdoor Activity Planner):**
   * Đánh giá mức độ phù hợp dựa trên nhiệt độ, chỉ số gió và thời tiết (nắng dịu, mưa bão, quá nắng nóng trên 35°C).
   * Đề xuất các môn thể thao hoặc hoạt động tối ưu: Chạy bộ công viên, đạp xe, cafe ngoài trời, hoặc chuyển sang gym/đọc sách trong nhà khi có dông.
3. **"Nên mặc trang phục gì khi ra ngoài?" (Outfit Guide):**
   * Dựa vào cảm nhận nhiệt thực tế (`apparent_temperature` / Feels-like) để tư vấn trang phục: áo cotton thoáng mát, nón mũ rộng vành, áo khoác mỏng cản gió hay áo ấm dày.
4. **Dự báo 24 giờ và 7 ngày tới (Hourly & 7-Day Forecast):**
   * Thanh cuộn ngang hiển thị nhiệt độ và xác suất mưa từng giờ.
   * Danh sách 7 ngày kèm dải nhiệt độ Min - Max trực quan.
5. **Tìm kiếm địa điểm toàn cầu qua REST Geocoding API:**
   * Cho phép gõ tìm bất kỳ thành phố nào trên thế giới (Hà Nội, Đà Nẵng, TP.HCM, Tokyo, London, Paris, New York...) và tải thời tiết tức thì.

---

### 3. Kiến Trúc Ứng Dụng (Architecture & Separation of Concerns)
Dự án được xây dựng theo kiến trúc phân tầng chuẩn (**Service Layer Pattern**):

```
lib/
├── main.dart                          # Điểm khởi chạy ứng dụng, cấu hình Theme & Locale
├── models/
│   ├── location_model.dart            # Model địa điểm (Geocoding API, danh sách thành phố phổ biến)
│   ├── weather_model.dart             # Model thời tiết (Current, Hourly, Daily, WMO Code)
│   └── weather_recommendation.dart    # Logic nghiệp vụ chuyển đổi số liệu thời tiết thành lời khuyên
├── services/
│   └── weather_service.dart           # Tầng Service: gọi REST API qua gói `http`, timeout, xử lý Exception
├── widgets/
│   ├── weather_header.dart            # Thẻ tiêu đề thời tiết chính (nhiệt độ, cảm giác thực, gió, độ ẩm)
│   ├── recommendation_cards.dart      # Các thẻ tư vấn thông minh (Dù, Thể thao ngoài trời, Trang phục)
│   ├── hourly_forecast_view.dart      # Dự báo thời tiết 24 giờ tới (dạng cuộn ngang)
│   ├── daily_forecast_view.dart       # Dự báo thời tiết 7 ngày tới (thanh nhiệt độ Min/Max)
│   ├── weather_details_grid.dart      # Lưới 4 chỉ số chi tiết (độ ẩm, tốc độ gió, mưa, cảm giác)
│   ├── city_search_sheet.dart         # BottomSheet tìm kiếm thành phố qua REST API Geocoding
│   └── error_view.dart                # Giao diện thông báo lỗi mạng kèm nút "Thử lại (Retry)"
└── screens/
    ├── home_screen.dart               # Màn hình chính kết hợp FutureBuilder, quản lý State
    └── detail_screen.dart             # Màn hình chi tiết bảng thông số khí quyển & kỹ thuật
```

---

### 4. Chi Tiết Tích Hợp REST API (API Integration)

#### 4.1. Endpoint Dự báo Thời tiết (Weather Forecast API)
* **Base URL:** `https://api.open-meteo.com/v1/forecast`
* **Phương thức:** `GET`
* **Tham số truy vấn (Query Parameters):**
  * `latitude`: Vĩ độ (ví dụ: `21.0285`)
  * `longitude`: Kinh độ (ví dụ: `105.8542`)
  * `current`: `temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m`
  * `hourly`: `temperature_2m,weather_code,precipitation_probability`
  * `daily`: `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max`
  * `timezone`: `auto`

#### 4.2. Endpoint Tìm kiếm Địa điểm (Geocoding Search API)
* **Base URL:** `https://geocoding-api.open-meteo.com/v1/search`
* **Phương thức:** `GET`
* **Tham số:** `name=<tên thành phố>&count=10&language=en&format=json`

#### 4.3. Xử lý Lỗi & Timeout trong Tầng Service (`WeatherService`)
* Sử dụng `.timeout(const Duration(seconds: 10))` phòng ngừa mất kết nối lâu.
* Bắt các ngoại lệ:
  * `SocketException`: Không có kết nối Internet / Mất sóng Wifi/4G.
  * `TimeoutException`: Quá thời gian chờ máy chủ phản hồi.
  * `FormatException`: Dữ liệu JSON bị hỏng hoặc sai cấu trúc.
  * Mã phản hồi HTTP khác `200`: Báo lỗi HTTP status code tương ứng.
* Tích hợp cờ `simulateError` để người dùng/giảng viên có thể nhấn nút **"Test Error State"** ngay trên giao diện nhằm kiểm tra màn hình lỗi và tính năng Retry.

---

### 5. Xử Lý Các Trạng Thái Giao Diện (State Handling)

1. **Trạng thái Đang tải (Loading State):**
   * Sử dụng `FutureBuilder` bắt trạng thái `ConnectionState.waiting`.
   * Hiển thị animation vòng xoay chỉ báo tiến trình (`CircularProgressIndicator`) cùng thông báo đang đồng bộ dữ liệu thời tiết qua REST API.
2. **Trạng thái Lỗi & Thử lại (Error & Retry State):**
   * Bắt trạng thái `snapshot.hasError`.
   * Hiển thị giao diện thân thiện: icon cảnh báo, chi tiết lỗi và nút bấm **"Thử lại (Retry)"** để kích hoạt lại API call mà không bị văng ứng dụng.
3. **Trạng thái Thành công (Success State):**
   * Dữ liệu được ánh xạ đầy đủ vào các Widget thẻ đẹp mắt, hỗ trợ kéo xuống để làm mới (`RefreshIndicator`).

---

### 6. Kết Quả Kiểm Thử (Automated Tests)
Toàn bộ mã nguồn đã vượt qua kiểm thử tự động với `flutter test` và `flutter analyze`:
* `LocationModel Tests`: Kiểm tra parse JSON, toạ độ, tên hiển thị.
* `WeatherModel Tests`: Kiểm tra parse số liệu thời tiết hiện tại, theo giờ và 7 ngày.
* `WeatherRecommendation Tests`: Kiểm tra thuật toán tự động đề xuất mang dù khi phát hiện trời mưa hoặc xác suất mưa cao.
* `Smoke Test`: Kiểm tra khởi động ứng dụng trơn tru không lỗi layout.

Kết quả chạy lệnh kiểm tra:
```bash
$ flutter analyze
Analyzing PRM393_Lab8B...
No issues found!

$ flutter test
00:01 +5: All tests passed!
```

---

### 7. Hướng Dẫn Chạy Ứng Dụng & Chụp Ảnh Báo Cáo

#### Cách chạy ứng dụng:
1. Mở terminal tại thư mục dự án `PRM393_Lab8B`.
2. Chạy lệnh:
   * Chạy trên trình duyệt Web (Chrome):
     ```bash
     flutter run -d chrome
     ```
   * Hoặc chạy trên Windows Desktop:
     ```bash
     flutter run -d windows
     ```

#### Hướng dẫn lấy ảnh minh chứng nộp bài (Screenshots):
* **Ảnh 1 - Giao diện chính thành công (Success State):** Hiển thị màn hình chính tại Hà Nội với nhiệt độ, thẻ Dù, Hoạt động ngoài trời, Trang phục, dự báo 24h & 7 ngày.
* **Ảnh 2 - Giao diện Đang tải (Loading State):** Xuất hiện khi vừa mở app hoặc khi đổi thành phố mới.
* **Ảnh 3 - Giao diện Báo lỗi & Nút Thử lại (Error & Retry State):** Nhấn nút **"Test Error State"** ở góc trên thanh công cụ để kích hoạt giao diện lỗi, sau đó nhấn **"Thử lại (Retry)"** để phục hồi.
* **Ảnh 4 - Tính năng Tìm kiếm thành phố (Search Sheet):** Mở thanh tìm kiếm, gõ tìm kiếm thành phố (ví dụ: Da Nang, Tokyo) hoặc chọn từ danh sách thành phố nhanh.
* **Ảnh 5 - Màn hình Phân tích Khí quyển Chi tiết (Detail Screen):** Nhấn nút "Xem thêm" tại mục chỉ số khí tượng để xem bảng thông số kỹ thuật và tọa độ.
